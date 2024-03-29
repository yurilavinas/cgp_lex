from abc import ABC, abstractmethod
from typing import List

import numpy as np

from kartezio.model.components import (
    GenomeReaderWriter,
    KartezioComponent,
    KartezioGenome,
    KartezioNode,
)
from kartezio.model.types import Score, ScoreList


class KartezioMetric(KartezioNode, ABC):
    def __init__(
        self,
        name: str,
        symbol: str,
        arity: int,
    ):
        super().__init__(name, symbol, arity, 0)

    def _to_json_kwargs(self) -> dict:
        pass


MetricList = List[KartezioMetric]


class KartezioFitness(KartezioNode, ABC):
    def __init__(
        self,
        name: str,
        symbol: str,
        arity: int,
        default_metric: KartezioMetric = None,
    ):
        super().__init__(name, symbol, arity, 0)
        self.metrics: MetricList = []
        if default_metric:
            self.add_metric(default_metric)

    def add_metric(self, metric: KartezioMetric):
        self.metrics.append(metric)

    def call(self, y_true, y_pred) -> ScoreList:
        scores: ScoreList = []
        for yi_pred in y_pred:
            scores.append(self.compute_one(y_true, yi_pred))
        return scores

    def compute_one(self, y_true, y_pred) -> Score:
        score = 0.0
        y_size = len(y_true)
        for i in range(y_size):
            _y_true = y_true[i].copy()
            _y_pred = y_pred[i]
            score += self.__fitness_sum(_y_true, _y_pred)
        return Score(score / y_size)

    def __fitness_sum(self, y_true, y_pred) -> Score:
        score = Score(0.0)
        for metric in self.metrics:
            score += metric.call(y_true, y_pred)
        return score

    def _to_json_kwargs(self) -> dict:
        pass


class KartezioMutation(GenomeReaderWriter, ABC):
    def __init__(self, shape, n_functions):
        super().__init__(shape)
        self.n_functions = n_functions
        self.parameter_max_value = 256

    def dumps(self) -> dict:
        return {}

    @property
    def random_parameters(self):
        return np.random.randint(self.parameter_max_value, size=self.shape.parameters)

    @property
    def random_functions(self):
        return np.random.randint(self.n_functions)

    @property
    def random_output(self):
        return np.random.randint(self.shape.out_idx, size=1)

    def random_connections(self, idx: int):
        return np.random.randint(
            self.shape.nodes_idx + idx, size=self.shape.connections
        )

    def mutate_function(self, genome: KartezioGenome, idx: int):
        self.write_function(genome, idx, self.random_functions)

    def mutate_connections(
        self, genome: KartezioGenome, idx: int, only_one: int = None
    ):
        new_connections = self.random_connections(idx)
        if only_one is not None:
            new_value = new_connections[only_one]
            new_connections = self.read_connections(genome, idx)
            new_connections[only_one] = new_value
        self.write_connections(genome, idx, new_connections)

    def mutate_parameters(self, genome: KartezioGenome, idx: int, only_one: int = None):
        new_parameters = self.random_parameters
        if only_one is not None:
            old_parameters = self.read_parameters(genome, idx)
            old_parameters[only_one] = new_parameters[only_one]
            new_parameters = old_parameters.copy()
        self.write_parameters(genome, idx, new_parameters)

    def mutate_output(self, genome: KartezioGenome, idx: int):
        self.write_output_connection(genome, idx, self.random_output)

    @abstractmethod
    def mutate(self, genome: KartezioGenome):
        pass


class KartezioPopulation(KartezioComponent, ABC):
    # changed
    def __init__(self, size, select_on):
        self.select_on = select_on
        # changed
        self.size = size
        self.individuals = [None] * self.size
        #changed
        self._fitness = {"fitness": np.zeros(self.size), "time": np.zeros(self.size), "act_nodes": np.zeros(self.size)}
        #changed
    def dumps(self) -> dict:
        return {}

    @abstractmethod
    def get_best_individual(self):
        pass

    def __getitem__(self, item):
        return self.individuals.__getitem__(item)

    def __setitem__(self, key, value):
        self.individuals.__setitem__(key, value)

    def set_time(self, individual, value):
        self._fitness["time"][individual] = value

    def set_fitness(self, fitness):
        self._fitness["fitness"] = fitness

    # changed
    def set_act_nodes(self, individual, act_nodes):
        self._fitness["act_nodes"][individual] = act_nodes
    # changed

    def has_best_fitness(self):
        return min(self.fitness) == 0.0

    @property
    def fitness(self):
        return self._fitness["fitness"]

    @property
    def time(self):
        return self._fitness["time"]
    #changed
    @property
    def act_nodes(self):
        return self._fitness["act_nodes"]
    #changed

    #changed
    @property
    def score(self):
        if self.select_on is None:
            return np.array(list(self.fitness))
        elif self.select_on == "fitness_act_nodes":
                act_nodes = self.act_nodes
                choice = np.random.choice([0,1], p = [0.7, 0.3])
                if choice == 0:
                    return np.array(list(self.fitness))
                else:
                    act_nodes_values = list(act_nodes)
                    return np.array(act_nodes_values)
        elif self.select_on == "lexicase":
            to_select_nodes = np.zeros(len(self.individuals))
            to_select_fitness = np.zeros(len(self.individuals)) 
            idx = np.argsort(self._fitness["act_nodes"])[0]
            best_act_nodes = self._fitness["act_nodes"][idx]
            sigma = np.median(np.median(self._fitness["act_nodes"]) - self._fitness["act_nodes"][idx])
            for i in range(len(self.individuals)):
                if (best_act_nodes + sigma) > self._fitness["act_nodes"][i]:
                    to_select_nodes[i] += 1

            idx = np.argsort(self._fitness["fitness"])[0]
            best_fitness = self._fitness["fitness"][idx]
            sigma = np.median(np.median(self._fitness["fitness"]) - self._fitness["fitness"][idx])
            for i in range(len(self.individuals)):
                if (best_fitness  + sigma) > self._fitness["fitness"][i]:
                    to_select_fitness[i] += 1
                
            to_select = -(to_select_fitness.astype(int) & to_select_fitness.astype(int))
            return to_select
            #changed

class KartezioES(ABC):
    @abstractmethod
    def selection(self):
        pass

    @abstractmethod
    def reproduction(self):
        pass
