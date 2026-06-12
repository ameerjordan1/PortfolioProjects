import streamlit as st
import pickle
import requests
import os
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# ---------------------------------------------------------------------------
# Movie Recommender System - Streamlit App
#
# This app loads precomputed movie data and a cosine similarity matrix
# (generated in Main.ipynb), lets the user pick a movie from a dropdown,
# and displays the top 5 most similar movies along with their posters
# fetched live from the TMDB (The Movie Database) API.
# ---------------------------------------------------------------------------


def fetch_poster(movie_id):
    """
    Given a TMDB movie ID, query the TMDB API and return the full URL
    to that movie's poster image. If no poster is available, return a
    placeholder image instead.
    """
    api_key = st.secrets["TMDB_API_KEY"]
    url = f"https://api.themoviedb.org/3/movie/{movie_id}?api_key={api_key}&language=en-US"
    data = requests.get(url).json()
    poster_path = data.get('poster_path')
    if poster_path:
        return "https://image.tmdb.org/t/p/w500/" + poster_path
    else:
        return "https://via.placeholder.com/500x750?text=No+Poster"


# ---------------------------------------------------------------------------
# Load precomputed data
#   - movies: dataframe with columns ['id', 'title', 'tags']
#   - similarity: cosine similarity matrix (numpy array), where
#     similarity[i][j] = similarity score between movie i and movie j
# ---------------------------------------------------------------------------
movies = pickle.load(open(os.path.join(BASE_DIR, "movies_list.pkl"), "rb"))
similarity = pickle.load(open(os.path.join(BASE_DIR, "similarity_topk.pkl"), "rb"))

# List of all movie titles, used to populate the dropdown selector
movies_list = movies['title'].values

st.header("Movie Recommender System")

# ---------------------------------------------------------------------------
# Optional: image carousel component (custom frontend widget)
# Displays a row of featured movie posters at the top of the app.
# ---------------------------------------------------------------------------
import streamlit.components.v1 as components

imageCarouselComponent = components.declare_component("image_carousel_component", path="frontend/public")

# A hardcoded list of TMDB movie IDs for the featured carousel at the top
imageUrls = [
    fetch_poster(1632),
    fetch_poster(299536),
    fetch_poster(17455),
    fetch_poster(2830),
    fetch_poster(429422),
    fetch_poster(9722),
    fetch_poster(13972),
    fetch_poster(240),
    fetch_poster(155),
    fetch_poster(598),
    fetch_poster(914),
    fetch_poster(255709),
    fetch_poster(572153)
]
imageCarouselComponent(imageUrls=imageUrls, height=200)

# Dropdown for the user to select a movie they like
selectvalue = st.selectbox("Select movie from dropdown", movies_list)


def recommend(movie):
    """
    Given a movie title, return two parallel lists:
      - recommend_movie:  titles of the top 5 most similar movies
      - recommend_poster: poster image URLs for those 5 movies

    Steps:
      1. Find the row index of the selected movie in `movies`.
      2. Look up that movie's row in the similarity matrix, which gives
         a similarity score against every other movie.
      3. Sort all (index, score) pairs by score in descending order.
      4. Skip index 0 (the movie itself, which always has a similarity
         of 1.0) and take the next 5 most similar movies.
    """
    index = int(movies[movies['title'] == movie].index[0])
    neighbor_indices = similarity["indices"][index]
    neighbor_scores = similarity["scores"][index]

    distance = list(zip(neighbor_indices, neighbor_scores))
    distance = sorted(distance, reverse=True, key=lambda x: x[1])

    recommend_movie = []
    recommend_poster = []
    for i in distance[1:6]:
        movies_id = movies.iloc[i[0]].id
        recommend_movie.append(movies.iloc[i[0]].title)
        recommend_poster.append(fetch_poster(movies_id))

    return recommend_movie, recommend_poster


# ---------------------------------------------------------------------------
# When the user clicks "Show Recommendation", compute and display the
# top 5 recommended movies (title + poster) side by side in 5 columns.
# ---------------------------------------------------------------------------
if st.button("Show Recommendation"):
    movie_name, movie_poster = recommend(selectvalue)
    col1, col2, col3, col4, col5 = st.columns(5)

    with col1:
        st.text(movie_name[0])
        st.image(movie_poster[0])
    with col2:
        st.text(movie_name[1])
        st.image(movie_poster[1])
    with col3:
        st.text(movie_name[2])
        st.image(movie_poster[2])
    with col4:
        st.text(movie_name[3])
        st.image(movie_poster[3])
    with col5:
        st.text(movie_name[4])
        st.image(movie_poster[4])
