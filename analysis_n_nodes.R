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
    data$population$fitness[1, ],
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
columns.name = c('Fitness',
                 'Time',
                 'Active nodes',
                 'Generation',
                 'Algorithm',
                 'iter')
data.files.cgp.lexicase <-
  list.files(dir, recursive = T, pattern = "rep_[0-9]*G[0-9]*.json")  # filenames in folder
list.lex = lapply(data.files.cgp.lexicase,  load.data, dir, 'CGP-LEX')
cgp.lexicase = create.data(list.lex, columns.name)


dir = "Documents/cgp/dist/results/cgp/"
data.files.cgp <-
  list.files(dir, recursive = T, pattern = "rep_[0-9]*G[0-9]*.json")  # filenames in folder
list.cgp = lapply(data.files.cgp,  load.data, dir, 'CGP')
cgp = create.data(list.cgp, columns.name)

# dir = "Documents/cgp/dist/results/fitness_act_nodes/"
# data.files.alternating <-
#   list.files(dir, recursive = T, pattern = "rep_[0-9]*G[0-9]*.json")  # filenames in folder
# list.alternating = lapply(data.files.alternating,  load.data, dir, 'CGP-Alt')
# alternating = create.data(list.alternating, columns.name)

# results = rbind(cgp, cgp.lexicase, alternating)
results = rbind(cgp, cgp.lexicase)

results$Fitness = 1 - as.numeric(results$Fitness)
results$`Active nodes` = as.numeric(results$`Active nodes`)
results$Generation = as.numeric(results$Generation)

mean.results = aggregate(results[1:3], mean, by = list(results$Algorithm, results$Generation))
colnames(mean.results) = c('Algorithm', 'Iteration',  'IOU', 'Time', 'Active nodes')

sd.results = aggregate(results[1:3], sd, by = list(results$Algorithm, results$Generation))
colnames(sd.results) = c('Algorithm', 'Iteration',  'IOU', 'Time', 'Active nodes')


v <- ggplot(
  data = mean.results,
  aes(
    x = Iteration,
    y = `Active nodes`,
    group = Algorithm,
    color = Algorithm,
    fill = Algorithm
  )
) + 
  geom_ribbon(
  aes(
    y = `Active nodes`,
    ymin = `Active nodes` - sd.results$`Active nodes`,
    ymax = `Active nodes` + sd.results$`Active nodes`,
    fill = Algorithm
  ),
  alpha = .2
) +
  geom_line(aes(color = Algorithm))  + theme_minimal(base_size = 30) + geom_point(aes(shape =
                                                                                          Algorithm))
print(v + theme(legend.position = 'bottom', legend.title = element_blank()))

dir = "Documents/cgp/dist/results/"
filename = paste0(dir, "n_nodes.png")
ggsave(
  filename = filename,
  dpi = 100,
  width = 14,
  height = 7
)

v <- ggplot(data = mean.results,
            aes(
              x = Iteration,
              y = IOU,
              group = Algorithm,
              color = Algorithm,
              fill = Algorithm
            )) +
  geom_ribbon(
              aes(
                y = mean.results$IOU,
                ymin = mean.results$IOU - sd.results$IOU,
                ymax = mean.results$IOU + sd.results$IOU,
                fill = Algorithm
              ),
              alpha = .2
            ) +
 geom_line(aes(color = Algorithm))  + theme_minimal(base_size = 30) + geom_point(aes(shape =
                                                                                                      Algorithm))
print(v + theme(legend.position = 'bottom', legend.title = element_blank()))

dir = "Documents/cgp/dist/results/"
filename = paste0(dir, "iou.png")
ggsave(
  filename = filename,
  dpi = 100,
  width = 14,
  height = 7
)

