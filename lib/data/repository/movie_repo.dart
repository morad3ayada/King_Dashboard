import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';

class MovieRepository {
  final _firestore = FirebaseFirestore.instance;
  final String _collection = 'movies';

  // Get all movies
  Future<List<MovieModel>> getAllMovies() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure id is set from document ID if not in data
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return MovieModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching movies: $e');
      return [];
    }
  }

  // Get movie by ID
  Future<MovieModel?> getMovieById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return MovieModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching movie: $e');
      return null;
    }
  }

  // Add new movie
  Future<bool> addMovie(MovieModel movie) async {
    try {
      await _firestore.collection(_collection).doc(movie.id).set(movie.toJson());
      return true;
    } catch (e) {
      print('Error adding movie: $e');
      return false;
    }
  }

  // Update movie
  Future<bool> updateMovie(MovieModel movie) async {
    try {
      await _firestore.collection(_collection).doc(movie.id).update(movie.toJson());
      return true;
    } catch (e) {
      print('Error updating movie: $e');
      return false;
    }
  }

  // Delete movie
  Future<bool> deleteMovie(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting movie: $e');
      return false;
    }
  }

  // Search movies by title
  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return MovieModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error searching movies: $e');
      return [];
    }
  }
}
