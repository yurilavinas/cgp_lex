from kartezio.apps.segmentation import create_segmentation_model
from kartezio.dataset import read_dataset
from kartezio.callback import CallbackVerbose,CallbackSave
from kartezio.endpoint import EndpointThreshold, EndpointWatershed, LocalMaxWatershed, EndpointEllipse
from kartezio.fitness import FitnessIOU
from kartezio.plot import plot_mask
import numpy as np
from kartezio.export import KartezioInsight
from kartezio.utils.viewer import KartezioViewer


DATASET_PATH = "./data/test_install/"
MODE = "semantic-ellipse" # "semantic", "semantic-ellipse", "instance-watershed", "instance-lm-watershed"

repetitions = 10
generations = 20000
_lambda = 5
inputs = 1 # one channel, grayscale
callback_frequency = 100


outputs = 1
endpoint = EndpointEllipse(min_axis=20, max_axis=60)
fitness = FitnessIOU()

for rep in [5,6,7,8,9,10]:
     
    print('rep', rep)
    dataset = read_dataset(DATASET_PATH)
    train_x, train_y, train_v = dataset.train_xyv

    callbacks = [
        CallbackSave(frequency=callback_frequency, workdir = './results/cgp_lexicase/rep_' + str(rep), dataset = dataset)
    ]

    cgp_lexicase = create_segmentation_model(
        generations=generations,
        _lambda=_lambda,
        inputs=inputs,
        nodes=30,
        outputs=outputs,
        fitness=fitness,
        callbacks=callbacks,
        endpoint=endpoint,
        select_on = "lexicase"
    )

    cgp_lexicase.fit(train_x, train_y)

    test_x, test_y, test_v = dataset.test_xyv
    y_hat, _ = cgp_lexicase.predict(test_x)
    for visual, y_pred, y_true in zip(test_v, y_hat, test_y):
        plot_mask(visual, y_pred["mask"].astype(np.uint8), gt=y_true[0])


    insight = KartezioInsight(cgp_lexicase.parser)
    insight.create_node_images(cgp_lexicase.strategy.best[0], dataset.test_x[0], prefix="./results/cgp_lexicase/images/" + str(rep) + "_cgp_lexicase")

    viewer = KartezioViewer(
        cgp_lexicase.parser.shape, cgp_lexicase.parser.function_bundle, cgp_lexicase.parser.endpoint
    )
    model_graph = viewer.get_graph(
        cgp_lexicase.strategy.best[0], inputs=["Gray"], outputs=["Mask"]
    )
    model_graph.draw(path="./results/cgp_lexicase/images/" + str(rep) + "_cgp_lexicase_graph_img.png")


    callbacks = [
        CallbackSave(frequency=callback_frequency, workdir = './results/cgp/rep_' + str(rep), dataset = dataset)
    ]

    cgp = create_segmentation_model(
        generations=generations,
        _lambda=_lambda,
        inputs=inputs,
        nodes=30,
        outputs=outputs,
        fitness=fitness,
        callbacks=callbacks,
        endpoint=endpoint,
        select_on = None
    )

    cgp.fit(train_x, train_y)

    test_x, test_y, test_v = dataset.test_xyv
    y_hat, _ = cgp.predict(test_x)
    for visual, y_pred, y_true in zip(test_v, y_hat, test_y):
        plot_mask(visual, y_pred["mask"].astype(np.uint8), gt=y_true[0])


    insight = KartezioInsight(cgp.parser)
    insight.create_node_images(cgp.strategy.best[0], dataset.test_x[0], prefix="./results/cgp/images/" + str(rep) + "_cgp")

    viewer = KartezioViewer(
        cgp.parser.shape, cgp.parser.function_bundle, cgp.parser.endpoint
    )
    model_graph = viewer.get_graph(
        cgp.strategy.best[0], inputs=["Gray"], outputs=["Mask"]
    )
    model_graph.draw(path="./results/cgp/images/" + str(rep) + "_cgp_graph_img.png")

