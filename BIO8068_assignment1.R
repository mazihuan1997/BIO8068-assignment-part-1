install.packages("warbleR")
library(warbleR)
library(behaviouR)
library(tuneR)
library(seewave)
library(ggplot2)
library(dplyr)

bluetit_songs <- query_xc(qword = 'Cyanistes caeruleus cnt:"united kingdom" type:song len:5-25', download = FALSE)
robin_songs <- query_xc(qword = 'Erithacus rubecula  cnt:"united kingdom" type:song len:5-25', download = FALSE)

map_xc(bluetit_songs, leaflet.map = TRUE)
map_xc(robin_songs, leaflet.map = TRUE)

# Create subfolders in your RStudio Project for bluetit and robin
dir.create(file.path("bluetit_songs"))
dir.create(file.path("robin_songs"))

# Download the .MP3 files into two separate sub-folders
query_xc(X = bluetit_songs, path="bluetit_songs")
query_xc(X = robin_songs, path="robin_songs")

#rename
library(stringr)

old_files <- list.files("bluetit_songs", full.names=TRUE)
new_files <- NULL
for(file in 1:length(old_files)){
  curr_file <- str_split(old_files[file], "-")
  new_name <- str_c(c(curr_file[[1]][1:2], "-song_", curr_file[[1]][3]), collapse="")
  new_files <- c(new_files, new_name)
}
file.rename(old_files, new_files)

old_files <- list.files("robin_songs", full.names=TRUE)
new_files <- NULL
for(file in 1:length(old_files)){
  curr_file <- str_split(old_files[file], "-")
  new_name <- str_c(c(curr_file[[1]][1:2], "-song_", curr_file[[1]][3]), collapse="")
  new_files <- c(new_files, new_name)
}
file.rename(old_files, new_files)

dir.create(file.path("audio"))
file.copy(from=paste0("bluetit_songs/",list.files("bluetit_songs")),
          to="audio")
file.copy(from=paste0("robin_songs/",list.files("robin_songs")),
          to="audio")

#change the file type
mp32wav(path="audio", dest.path="audio")
unwanted_mp3 <- dir(path="audio", pattern="*.mp3")
file.remove(paste0("audio/", unwanted_mp3))

#oscillograms of two bird songs
bird_wav <- readWave("audio/Cyanistescaeruleus-song_133817.wav")
bird_wav
oscillo(bird_wav)
oscillo(bird_wav, from = 0.59, to = 0.60)

bird_wav2 <- readWave("audio/Erithacusrubecula-song_296863.wav")
bird_wav2
oscillo(bird_wav2)
oscillo(bird_wav2, from = 0.59, to = 0.60)

#Spectrograms of two bird songs
SpectrogramSingle(sound.file = "audio/Cyanistescaeruleus-song_133817.wav",
                  Colors = "Colors")
SpectrogramSingle(sound.file = "audio/Erithacusrubecula-song_296863.wav",
                  Colors = "Colors")

#mfcc
bird_mfcc <- MFCCFunction(input.dir = "audio",
                               max.freq=8000)
dim(bird_mfcc)

library(vegan) 
source("nes8010.R")

#pca
bird_pca <- ordi_pca(bird_mfcc[, -1], scale=TRUE)
summary(bird_pca)

bird_sco <- ordi_scores(bird_pca, display="sites")
bird_sco <- mutate(bird_sco, group_code = bird_mfcc$Class)

ggplot(bird_sco, aes(x=PC1, y=PC2, colour=group_code)) +
  geom_point() 





