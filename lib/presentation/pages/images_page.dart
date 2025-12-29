import 'package:flutter/material.dart';
import '../../data/models/movie_model.dart';
import '../../data/repository/movie_repo.dart';
import 'package:url_launcher/url_launcher.dart';

class ImagesPage extends StatefulWidget {
  const ImagesPage({super.key});

  @override
  State<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  final _repo = MovieRepository();
  List<MovieModel> _movies = [];
  List<MovieModel> _filteredMovies = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);
    final movies = await _repo.getAllMovies();
    setState(() {
      _movies = movies;
      _filteredMovies = movies;
      _isLoading = false;
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showMessage('Could not launch original image link', isError: true);
    }
  }

  void _filterMovies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMovies = _movies;
      } else {
        _filteredMovies = _movies.where((movie) {
          return movie.title.toLowerCase().contains(query.toLowerCase()) ||
                 (movie.category?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _showMovieDetails(MovieModel movie) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
          child: Column(
            children: [
              // Header
              AppBar(
                title: Text(movie.title),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () => _launchURL(movie.imageUrl),
                    tooltip: 'Open Image in Browser',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditMovieDialog(movie);
                    },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _deleteMovie(movie);
                    },
                    tooltip: 'Delete',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster Image
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              movie.imageUrl,
                              width: 300,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 300,
                                  height: 450,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.broken_image, size: 64, color: Colors.red),
                                      const SizedBox(height: 16),
                                      const Text('Image failed to load', style: TextStyle(color: Colors.red)),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () => _launchURL(movie.imageUrl),
                                        child: const Text('Open in Browser'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('If image fails to load, it might be due to CORS on Web.', 
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Image URL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  SelectableText(
                                    movie.imageUrl,
                                    style: TextStyle(fontSize: 12, color: Colors.blue[800], fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (movie.year != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Year: ${movie.year}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (movie.category != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.category, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Category: ${movie.category}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (movie.rating != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Text('Rating: ${movie.rating}'),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (movie.description != null) ...[
                              const Text(
                                'Description:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                movie.description!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddMovieDialog() async {
    final titleController = TextEditingController();
    final imageUrlController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final yearController = TextEditingController();
    final ratingController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Movie'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.movie),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Image URL *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.image),
                    hintText: 'https://example.com/poster.jpg',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () {
                        if (imageUrlController.text.isNotEmpty) {
                          _launchURL(imageUrlController.text.trim());
                        }
                      },
                      tooltip: 'Test link in browser',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                    hintText: 'Action, Drama, Comedy...',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: yearController,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                          hintText: '2024',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: ratingController,
                        decoration: const InputDecoration(
                          labelText: 'Rating',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.star),
                          hintText: '8.5',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    hintText: 'Movie description...',
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty || imageUrlController.text.trim().isEmpty) {
                _showMessage('Title and Image URL are required', isError: true);
                return;
              }

              final newMovie = MovieModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text.trim(),
                imageUrl: imageUrlController.text.trim(),
                description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                category: categoryController.text.trim().isEmpty ? null : categoryController.text.trim(),
                year: yearController.text.trim().isEmpty ? null : yearController.text.trim(),
                rating: ratingController.text.trim().isEmpty ? null : ratingController.text.trim(),
              );

              final success = await _repo.addMovie(newMovie);
              
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  _showMessage('Movie added successfully');
                  _loadMovies();
                } else {
                  _showMessage('Failed to add movie', isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Movie'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditMovieDialog(MovieModel movie) async {
    final titleController = TextEditingController(text: movie.title);
    final imageUrlController = TextEditingController(text: movie.imageUrl);
    final descriptionController = TextEditingController(text: movie.description ?? '');
    final categoryController = TextEditingController(text: movie.category ?? '');
    final yearController = TextEditingController(text: movie.year ?? '');
    final ratingController = TextEditingController(text: movie.rating ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Movie'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.movie),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Image URL *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.image),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () {
                        if (imageUrlController.text.isNotEmpty) {
                          _launchURL(imageUrlController.text.trim());
                        }
                      },
                      tooltip: 'Test link in browser',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: yearController,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: ratingController,
                        decoration: const InputDecoration(
                          labelText: 'Rating',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.star),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty || imageUrlController.text.trim().isEmpty) {
                _showMessage('Title and Image URL are required', isError: true);
                return;
              }

              final updatedMovie = MovieModel(
                id: movie.id,
                title: titleController.text.trim(),
                imageUrl: imageUrlController.text.trim(),
                description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                category: categoryController.text.trim().isEmpty ? null : categoryController.text.trim(),
                year: yearController.text.trim().isEmpty ? null : yearController.text.trim(),
                rating: ratingController.text.trim().isEmpty ? null : ratingController.text.trim(),
              );

              final success = await _repo.updateMovie(updatedMovie);
              
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  _showMessage('Movie updated successfully');
                  _loadMovies();
                } else {
                  _showMessage('Failed to update movie', isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Movie'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMovie(MovieModel movie) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${movie.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _repo.deleteMovie(movie.id);
      if (success) {
        _showMessage('Movie deleted successfully');
        _loadMovies();
      } else {
        _showMessage('Failed to delete movie', isError: true);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search movies by title or category...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: _filterMovies,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _showAddMovieDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Movie'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMovies,
              tooltip: 'Refresh',
              iconSize: 28,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.movie, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Total Movies: ${_movies.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_searchController.text.isNotEmpty) ...[
                const SizedBox(width: 16),
                Text(
                  'Showing: ${_filteredMovies.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredMovies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.movie_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No movies found in Firestore'
                                : 'No movies match your search',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _filteredMovies.length,
                      itemBuilder: (context, index) {
                        final movie = _filteredMovies[index];
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 4,
                          child: InkWell(
                            onTap: () => _showMovieDetails(movie),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Movie Poster
                                Expanded(
                                  child: Image.network(
                                    movie.imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.broken_image, size: 48, color: Colors.red),
                                            const SizedBox(height: 8),
                                            TextButton(
                                              onPressed: () => _launchURL(movie.imageUrl),
                                              child: const Text('Open Link', style: TextStyle(fontSize: 10)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Movie Info
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.black87,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (movie.year != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          movie.year!,
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                      if (movie.rating != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              size: 12,
                                              color: Colors.amber,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              movie.rating!,
                                              style: const TextStyle(
                                                color: Colors.amber,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
