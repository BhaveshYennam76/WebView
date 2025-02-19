/// Entrypoint of the application.
import 'dart:convert'; // Import for encoding
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const ImageLoader());
}

class ImageLoader extends StatefulWidget {
  const ImageLoader({super.key});

  @override
  State<ImageLoader> createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<ImageLoader> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  bool isFullscreen = false;

  void _toggleFullscreen() {
    if (isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    setState(() {
      isFullscreen = !isFullscreen;
    });
  }

  void _showMenu(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeMenu,
              child: Container(color: Colors.black54),
            ),
          ),
          Positioned(
            width: 200,
            child: CompositedTransformFollower(
              link: _layerLink,
              offset: const Offset(-150, -50),
              child: Material(
                color: Colors.white,
                elevation: 5,
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMenuItem("Enter fullscreen", !isFullscreen),
                    _buildMenuItem("Exit fullscreen", isFullscreen),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildMenuItem(String text, bool isVisible) {
    if (!isVisible) return SizedBox.shrink();
    return InkWell(
      onTap: () {
        _toggleFullscreen();
        _removeMenu();
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  void _removeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  final TextEditingController _controller = TextEditingController();
  late WebViewController _webViewController;
  String _imageUrl = ""; // Store the current image URL

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent); // Set background to transparent
  }

  void _loadImage() {
    setState(() {
      _imageUrl = _controller.text; // Update the _imageUrl
    });

    if (_imageUrl.isNotEmpty) {
      _webViewController.loadRequest(
        Uri.dataFromString(
          _generateHtml(_imageUrl), // Use _generateHtml function
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ),
      );
    }
  }

  String _generateHtml(String imageUrl) {
    return '''
    <html>
    <body style="display:flex; justify-content:center; align-items:center; height:100vh; background-color:transparent;">
      <img src="$imageUrl" style="max-width:100%; max-height:100%; object-fit:contain;" onload="imageLoaded()" onerror="this.onerror=null; this.src='https://via.placeholder.com/300';"/>
      <script>
        function imageLoaded() {
          // This function will be called when the image has loaded.
          console.log("Image loaded!"); // Optional: For debugging
          // You can add any JavaScript code here to interact with the image
          // after it has loaded.  For example, if you need to access
          // the image's dimensions, you would do it here.
        }
      </script>
    </body>
    </html>
  ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                     decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: WebViewWidget(
                    controller: _webViewController,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Image URL',
                      border: OutlineInputBorder(),
                      labelText: 'Enter Image URL',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _loadImage,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                    child: Icon(Icons.arrow_forward),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
      floatingActionButton: CompositedTransformTarget(
        link: _layerLink,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(Colors.green),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                side: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          onPressed: () => _showMenu(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
// /// Application itself.
// class ImageLoader extends StatefulWidget {
//   const ImageLoader({super.key});
//
//   @override
//   State<ImageLoader> createState() => _ImageLoaderState();
// }
//
// class _ImageLoaderState extends State<ImageLoader> {
//   TextEditingController _controller = TextEditingController();
//   String? _imageUrl;
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       home: const HomePage(),
//     );
//   }
// }
//
// /// [Widget] displaying the home page consisting of an image the the buttons.
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// /// State of a [HomePage].
// class _HomePageState extends State<HomePage> {
//   OverlayEntry? _overlayEntry;
//   final LayerLink _layerLink = LayerLink();
//
//   bool isFullscreen = false;
//
//   void _toggleFullscreen() {
//     if (isFullscreen) {
//       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     } else {
//       SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     }
//     setState(() {
//       isFullscreen = !isFullscreen;
//     });
//   }
//
//   void _showMenu(BuildContext context) {
//     _overlayEntry = OverlayEntry(
//       builder:
//           (context) => Stack(
//             children: [
//               // Dimming Background
//               Positioned.fill(
//                 child: GestureDetector(
//                   onTap: _removeMenu,
//                   child: Container(color: Colors.black54),
//                 ),
//               ),
//               // Context Menu
//               Positioned(
//                 width: 200,
//                 child: CompositedTransformFollower(
//                   link: _layerLink,
//                   offset: Offset(-150, -50), // Position above the button
//                   child: Material(
//                     color: Colors.white,
//                     elevation: 5,
//                     borderRadius: BorderRadius.circular(8),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         _buildMenuItem("Enter fullscreen", !isFullscreen),
//                         _buildMenuItem("Exit fullscreen", isFullscreen),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//     );
//
//     Overlay.of(context).insert(_overlayEntry!);
//   }
//
//   Widget _buildMenuItem(String text, bool isVisible) {
//     if (!isVisible) return SizedBox.shrink();
//     return InkWell(
//       onTap: () {
//         _toggleFullscreen();
//         _removeMenu();
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Text(text, style: TextStyle(fontSize: 16)),
//       ),
//     );
//   }
//
//   void _removeMenu() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }
//
//   TextEditingController _controller = TextEditingController();
//   late final WebViewController _webViewController;
//   var image = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _webViewController =
//         WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
//   }
//
//   void _loadImage() {
//     String imageUrl = _controller.text;
//
//     if (imageUrl.isNotEmpty) {
//       String htmlContent = '''
//       <html>
//       <body style="display:flex; justify-content:center; align-items:center; height:100vh; background-color:#f0f0f0;">
//         <img src="$imageUrl" style="width:300px; height:300px; object-fit:cover; border:2px solid black;" onerror="this.onerror=null; this.src='https://via.placeholder.com/300';"/>
//       </body>
//       </html>
//       ''';
//
//       _webViewController.loadRequest(
//         Uri.dataFromString(
//           htmlContent,
//           mimeType: 'text/html',
//           encoding: Encoding.getByName('utf-8'),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Padding(
//         padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Expanded(
//               child: AspectRatio(
//                 aspectRatio: 1,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: WebViewWidget(controller: _webViewController,),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     onChanged: (value) {
//                       setState(() {
//                         image = value;
//                       });
//                     },
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'Image URL',
//                       border: OutlineInputBorder(),
//                       labelText: 'Enter Image URL',
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: _loadImage,
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
//                     child: Icon(Icons.arrow_forward),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 64),
//           ],
//         ),
//       ),
//       floatingActionButton: CompositedTransformTarget(
//         link: _layerLink,
//         child: ElevatedButton(
//           style: ButtonStyle(
//             backgroundColor: WidgetStatePropertyAll(Colors.green),
//             shape: WidgetStatePropertyAll(
//               RoundedRectangleBorder(
//                 side: BorderSide(width: 2),
//                 borderRadius: BorderRadius.all(Radius.circular(10)),
//               ),
//             ),
//           ),
//           onPressed: () => _showMenu(context),
//           child: Icon(Icons.add),
//         ),
//       ),
//     );
//   }
// }
