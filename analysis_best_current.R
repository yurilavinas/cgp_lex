rm(list = ls(all = TRUE))

cgp.lexicase = read.csv("Documents/cgp/dist/results/current_best_lexicase.txt", header = F)
cgp.lexicase = cbind(cgp.lexicase, Algorithm = 'CGP-LEX')
colnames(cgp.lexicase) = c('Fitness', 'Active nodes', 'generation', 'Algorithm')


cgp = read.csv("Documents/cgp/dist/results/current_best_Best.txt", header = F)
cgp = cbind(cgp, Algorithm = 'CGP')
colnames(cgp) = c('Fitness', 'Active nodes', 'generation', 'Algorithm')

alternating = read.csv("Documents/cgp/dist/results/current_best_fitness-act_nodes.txt", header = F)
alternating = cbind(alternating, Algorithm = 'CGP-Alt')
colnames(alternating) = c('Fitness', 'Active nodes', 'generation', 'Algorithm')

results = rbind(cgp, cgp.lexicase, alternating)
results = rbind(cgp, cgp.lexicase)

results$Fitness = as.numeric(results$Fitness)
results$`Active nodes` = as.numeric(results$`Active nodes`)
results$generation = as.numeric(results$generation)

mean.results = aggregate(results[1:2], mean, by = list(results$Algorithm, results$generation))
sd.results = aggregate(results[1:2], sd, by = list(results$Algorithm, results$generation))
colnames(mean.results) = c('Algorithm', 'Iteration',  'IOU', 'Active nodes')

mean.results$Iteration = as.numeric(mean.results$Iteration)
mean.results$IOU = 1 - as.numeric(mean.results$IOU)
v <- ggplot(data = mean.results,
            aes(
              x = Iteration,
              y = IOU,
              group = Algorithm,
              color = Algorithm,
              fill = Algorithm
            ))  + geom_line(aes(color = Algorithm))  + theme_minimal(base_size = 30) + geom_point(aes(shape=Algorithm))
print(v + theme(legend.position = 'bottom', legend.title = element_blank()))

dir = "Documents/cgp/dist/results/"
filename = paste0(dir, "best_current_iou_evolution.png")
ggsave(
  filename = filename,
  dpi = 150,
  width = 14,
  height = 7
)
