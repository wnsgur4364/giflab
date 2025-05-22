import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'uploadDetailPage.dart';
import 'dart:io';

class UploadStylePage extends StatefulWidget {
  const UploadStylePage({super.key});

  @override
  State<UploadStylePage> createState() => _UploadStylePageState();
}

class _UploadStylePageState extends State<UploadStylePage> {
  List<AssetEntity> _images = [];
  AssetEntity? _selectedAsset;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return;

    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    final recent = albums.first;
    final photos = await recent.getAssetListPaged(page: 0, size: 100);

    setState(() {
      _images = photos;
      if (photos.isNotEmpty) {
        _selectedAsset = photos[0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('새 게시물', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () async {
              if (_selectedAsset != null) {
                final file = await _selectedAsset!.file;
                if (file != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadDetailPage(imageFile: file),
                    ),
                  );
                }
              }
            },
            child: const Text('다음', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔼 상단 미리보기
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.grey[900],
              child: _selectedAsset != null
                  ? FutureBuilder<Uint8List?>(
                      future: _selectedAsset!
                          .thumbnailDataWithSize(const ThumbnailSize(600, 600)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.memory(snapshot.data!, fit: BoxFit.cover);
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    )
                  : const Icon(Icons.image, color: Colors.white70, size: 60),
            ),
          ),

          // 🔽 하단 GridView
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              itemCount: _images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                final asset = _images[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAsset = asset;
                    });
                  },
                  child: FutureBuilder<Uint8List?>(
                    future: asset.thumbnailDataWithSize(
                        const ThumbnailSize(200, 200)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return Image.memory(snapshot.data!, fit: BoxFit.cover);
                      } else {
                        return Container(color: Colors.grey[800]);
                      }
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
