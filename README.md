## miniProject05

Students:
Valeria Fernanda Gustín Martínez
Maria Paula Castillo Erazo

Teacher:
Francisco Suarez

### Data sounder
For this project, we selected a dataBsae that lists the most famous songs of 2023 on Spotify. We cleaned the data using R, and decided to work with the following variables:
- track_name
- mode
- bpm
- danceability
- energy
- valence
- spotify charts

#### Visualization
We employed Processing, to create dynamic visual representations of the data. Each song's attributes are depicted through various visual elements:

Happy face: Its color represents the valence of the track, indicating its positivity or negativity. Its smile represents valence, the bigger the smile, the higher the valence.
Drawing of a person dancing: Fast motion in the arms and large size indicates high danceability
Ball in flames: Corresponds to the energy level.
Fractal tree: Its branches expand as the value of danceability grows.
Ball: the faster it moves, the higher the bpm is.

#### Sonification
To complement the visualizations, we implemented sonification using Pure Data (Pd), an open-source visual programming language for multimedia. By mapping data attributes to sound parameters, we created auditory representations of the songs:

- Drum machine: the variable bpm is the bpm value of the machine, the variable mode set the snare value: 1 if mode is Major, or 0 if mode is Minor.
- Frequency and volume: controlled given the values of danceability and energy.
- Piano: the value of valence changes the instrument for the piano note.

[DataBase]:(https://www.kaggle.com/datasets/nelgiriyewithana/top-spotify-songs-2023)
