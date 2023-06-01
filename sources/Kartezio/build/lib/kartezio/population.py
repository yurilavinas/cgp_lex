import numpy as np

from kartezio.model.evolution import KartezioPopulation


class IndividualHistory:
    def __init__(self):
        self.fitness = {"fitness": 0.0, "time": 0.0}
        self.sequence = None

    def set_sequence(self, sequence):
        self.sequence = sequence

    def set_values(self, sequence, fitness, time, act_nodes):        # changed
        self.sequence = sequence
        self.fitness["fitness"] = fitness
        self.fitness["time"] = time
        # changed
        self.fitness["act_nodes"] = act_nodes 
        # changed

class PopulationHistory:
    def __init__(self, n_individuals):
        self.individuals = {}
        for i in range(n_individuals):
            self.individuals[i] = IndividualHistory()

    # changed
    def fill(self, individuals, fitness, times, act_nodes):
        for i in range(len(individuals)):
            self.individuals[i].set_values(
                individuals[i].sequence, float(fitness[i]), float(times[i]), float(act_nodes[i])
            )
    # changed

    def get_best_fitness(self):
        return (
            self.individuals[0].fitness["fitness"],
            self.individuals[0].fitness["time"],
        )

    def get_individuals(self):
        return self.individuals.items()

# changed
class PopulationWithElite(KartezioPopulation):
    def __init__(self, _lambda, select_on):
        super().__init__(1 + _lambda, select_on)
        # changed

    def set_elite(self, individual):
        self[0] = individual

    def get_elite(self):
        return self[0]

    def get_best_individual(self):
        # get the first element to minimize
        best_fitness_idx = np.argsort(self.score)[0]
        best_individual = self[best_fitness_idx]
        # changed
        return best_individual, self.fitness[best_fitness_idx], best_fitness_idx
        # changed

    def history(self):
        population_history = PopulationHistory(self.size)
        # changed
        population_history.fill(self.individuals, self.fitness, self.time, self.act_nodes)
        # changed
        return population_history
