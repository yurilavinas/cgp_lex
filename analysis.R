rm(list = ls(all = TRUE))

library("jsonlite")
library(dplyr)
library(ggplot2)


load.data = function(filename, dir, algorithm) {
  data = fromJSON(paste0(dir, filename))
  tmp = strsplit(filename, '.json')[[1]]
  tmp = strsplit(tmp, 'rep_')[[1]][2]
  tmp = strsplit(tmp, 'G')[[1]]
  
  iter = tmp[1]
  gen = tmp[2]
  
  cbind(
    data$population$fitness[1,],
    gen = gen,
    algorithm = algorithm,
    iter = iter
    )
}

create.data = function(data.list, columns.name) {
  data = bind_rows(data.list)
  colnames(data) <- columns.name
  data
}

dir = "Documents/cgp/dist/results/cgp_lexicase/"
columns.name = c('Fitness', 'Time', 'Active nodes', 'Generation', 'Algorithm', 'iter')
data.files.cgp.lexicase <-
  list.files(dir, recursive = T, pattern = "rep_[0-9]*G[0-9]*.json")  # filenames in folder
list.lex = lapply(data.files.cgp.lexicase,  load.data, dir, 'CGP-LEX')
cgp.lexicase = create.data(list.lex, columns.name)
  

dir = "Documents/cgp/dist/results/cgp/"
data.files.cgp <-
  list.files(dir, recursive = T, pattern = "rep_[0-9]*G[0-9]*.json")  # filenames in folder
list.cgp = lapply(data.files.cgp,  load.data, dir, 'CGP')
cgp = create.data(list.cgp, columns.name)

dir = "Documents/cgp/dist/results/fitness_act_nodes/"
data.files.alternating <-
  list.files(dir, recursive = T, pattern = "rep_[0-9]*G[0-9]*.json")  # filenames in folder
list.alternating = lapply(data.files.alternating,  load.data, dir, 'CGP - Alternating metrics')
alternating = create.data(list.alternating, columns.name)

results = rbind(cgp, cgp.lexicase, alternating)

results$Fitness = 1 - as.numeric(results$Fitness)
results$`Active nodes` = as.numeric(results$`Active nodes`)
results$Generation = as.numeric(results$Generation)

mean.results = aggregate(results[1:3], mean, by = list(results$Algorithm, results$Generation))
colnames(mean.results) = c('Algorithm', 'Generation',  'IOU', 'Time', 'Active nodes')

mean.results$Generation = as.numeric(mean.results$Generation)
v <- ggplot(data = mean.results,
            aes(
              x = Generation,
              y = IOU,
              group = Algorithm,
              color = Algorithm,
              fill = Algorithm
            )) + geom_line(aes(color = Algorithm)) #+ ylim(c(0.2,1))
print(v + theme(legend.position = 'bottom', legend.title = element_blank()))

dir = "Documents/cgp/dist/results/"
filename = paste0(dir, "current_best_iou.png")
ggsave(
  filename = filename,
  dpi = 150,
  width = 14,
  height = 7
)


v <- ggplot(data = mean.results,
            aes(
              x = Generation,
              y = `Active nodes`,
              group = Algorithm,
              color = Algorithm,
              fill = Algorithm
            )) + geom_line(aes(color = Algorithm)) 
print(v + theme(legend.position = 'bottom', legend.title = element_blank()))

dir = "Documents/cgp/dist/results/"
filename = paste0(dir, "n_nodes.png")
ggsave(
  filename = filename,
  dpi = 150,
  width = 14,
  height = 7
)
# =========================================================================================================
# =========================================================================================================
# =========================================================================================================
rm(list = ls(all = TRUE))

cgp.lexicase = read.csv("Documents/cgp/dist/results/overall_best_lexicase.txt", header = F)
cgp.lexicase = cbind(cgp.lexicase, Algorithm = 'CGP-LEX')
colnames(cgp.lexicase) = c('Fitness', 'Active nodes', 'generation', 'Algorithm')


cgp = read.csv("Documents/cgp/dist/results/overall_best_Best.txt", header = F)
cgp = cbind(cgp, Algorithm = 'CGP')
colnames(cgp) = c('Fitness', 'Active nodes', 'generation', 'Algorithm')

# alternating = read.csv("Documents/cgp/dist/results/overall_best_fitness-act_nodes.txt", header = F)
# alternating = cbind(alternating, Algorithm = 'CGP - Alternating metrics')
# colnames(alternating) = c('Fitness', 'Active nodes', 'generation', 'Algorithm')

results = rbind(cgp, cgp.lexicase)
# results = rbind(cgp, cgp.lexicase, alternating)

results$Fitness = as.numeric(results$Fitness)
results$`Active nodes` = as.numeric(results$`Active nodes`)
results$generation = as.numeric(results$generation)

mean.results = aggregate(results[1:2], mean, by = list(results$Algorithm, results$generation))
sd.results = aggregate(results[1:2], sd, by = list(results$Algorithm, results$generation))
colnames(mean.results) = c('Algorithm', 'Generation',  'IOU', 'Active nodes')

mean.results$Generation = as.numeric(mean.results$Generation)
mean.results$IOU = 1 - as.numeric(mean.results$IOU)
v <- ggplot(data = mean.results,
            aes(
              x = Generation,
              y = IOU,
              group = Algorithm,
              color = Algorithm,
              fill = Algorithm
            ))  + geom_line(aes(color = Algorithm)) #+ ylim(c(0.2,1))
print(v + theme(legend.position = 'bottom', legend.title = element_blank()))

dir = "Documents/cgp/dist/results/"
filename = paste0(dir, "best_ever_iou_evolution.png")
ggsave(
  filename = filename,
  dpi = 150,
  width = 14,
  height = 7
)

# =========================================================================================================
# =========================================================================================================
# =========================================================================================================


cgp.lexicase = read.csv("Documents/cgp/dist/results/current_best_lexicase.txt", header = F)
cgp.lexicase = cbind(cgp.lexicase, Algorithm = 'CGP-LEX')
colnames(cgp.lexicase) = c('Fitness', 'Active nodes', 'generation', 'Algorithm')


cgp = read.csv("Documents/cgp/dist/results/current_best_Best.txt", header = F)
cgp = cbind(cgp, Algorithm = 'CGP')
colnames(cgp) = c('Fitness', 'Active nodes', 'generation', 'Algorithm')

# alternating = read.csv("Documents/cgp/dist/results/current_best_fitness-act_nodes.txt", header = F)
# alternating = cbind(alternating, Algorithm = 'CGP - Alternating metrics')
# colnames(alternating) = c('Fitness', 'Active nodes', 'generation', 'Algorithm')


# results = rbind(cgp, cgp.lexicase, alternating)
results = rbind(cgp, cgp.lexicase)

results$Fitness = as.numeric(results$Fitness)
results$`Active nodes` = as.numeric(results$`Active nodes`)
results$generation = as.numeric(results$generation)

mean.results = aggregate(results[1:2], mean, by = list(results$Algorithm, results$generation))
sd.results = aggregate(results[1:2], sd, by = list(results$Algorithm, results$generation))
colnames(mean.results) = c('Algorithm', 'Generation',  'IOU', 'Active nodes')

mean.results$Generation = as.numeric(mean.results$Generation)
mean.results$IOU = 1 - as.numeric(mean.results$IOU)
v <- ggplot(data = mean.results,
            aes(
              x = Generation,
              y = IOU,
              group = Algorithm,
              color = Algorithm,
              fill = Algorithm
            ))  + geom_line(aes(color = Algorithm)) + theme_minimal(base_size = 20)
print(v + theme(legend.position = 'bottom', legend.title = element_blank()))

dir = "Documents/cgp/dist/results/"
filename = paste0(dir, "best_current_iou_evolution.png")
ggsave(
  filename = filename,
  dpi = 150,
  width = 14,
  height = 7
)

