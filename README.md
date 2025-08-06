# Cineverse 🎬

A modern, feature-rich movie discovery application built with Flutter. Cineverse allows users to explore trending, popular, and top-rated movies, search for their favorites, and maintain a personal watchlist, all with a clean, responsive UI and full offline support.

---

## 📸 Screenshots

| Home Page | Search Page | Detail Page |
| :---: | :---: | :---: |
| ![Home Page](https://raw.githubusercontent.com/sagar-ksahoo/cineverse/master/screenshots/home.jpg) | ![Search Page](https://raw.githubusercontent.com/sagar-ksahoo/cineverse/master/screenshots/search.jpg) | ![Detail Page](https://raw.githubusercontent.com/sagar-ksahoo/cineverse/master/screenshots/detail.jpg) |

---

## ✨ Features

- **Discover Movies:** Browse multiple lists of movies including Trending, Now Playing, Popular, and Top Rated.
- **Rich Movie Details:** View detailed information for any movie, including backdrop and poster images, genres, runtime, overview, and a full cast list.
- **Advanced Search:** A dedicated search tab with a "live search" feature that updates results automatically as you type.
- **Personal Watchlist:** Bookmark your favorite movies and view them on a dedicated "Saved" page.
- **Full Offline Support:**
  - The home page caches movie lists, making them available even without an internet connection.
  - Your personal watchlist is stored locally and is always accessible offline.
- **Responsive UI:** The layout is designed to be clean and functional on a variety of screen sizes.
- **Sharing:** Share your favorite movies with friends using a generated "deep link."

---

## 🛠️ Tech Stack & Architecture

- **Framework:** Flutter
- **Architecture:** MVVM (Model-View-ViewModel) with the Repository Pattern
- **State Management:** Provider
- **Networking:** `Retrofit` & `Dio` for type-safe API calls
- **Local Storage:** `sqflite` for the local database (bookmarks & caching)
- **Code Generation:** `json_serializable` & `build_runner`
- **API:** [The Movie Database (TMDB) API](https://developers.themoviedb.org/3/getting-started/introduction)

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- You must have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed on your machine.
- An API key from [The Movie Database (TMDB)](https://www.themoviedb.org/signup).

### Installation

1. **Clone the repo**
    ```sh
    git clone [https://github.com/sagar-ksahoo/cineverse.git](https://github.com/sagar-ksahoo/cineverse.git)
    ```
2. **Navigate to the project directory**
    ```sh
    cd cineverse
    ```
3. **Install packages**