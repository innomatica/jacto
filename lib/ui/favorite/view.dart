import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'model.dart';

class FavoriteView extends StatelessWidget {
  final FavoriteViewModel model;
  const FavoriteView({super.key, required this.model});

  Widget _buildBody(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 16,
      color: Theme.of(context).colorScheme.primary,
    );
    final keywordStyle = TextStyle(fontSize: 12);
    final descriptionStyle = TextStyle(fontWeight: FontWeight.w300);

    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        return SingleChildScrollView(
          child: Column(
            children:
                model.items.map((e) {
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title ?? "unknown title", style: titleStyle),
                        Text(
                          e.keywords ?? "",
                          style: keywordStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    subtitle: Text(
                      e.description ?? "",
                      style: descriptionStyle,
                    ),
                    onTap: () {
                      context.go(
                        Uri(
                          path: "/channel",
                          queryParameters: {"url": e.url},
                        ).toString(),
                      );
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: () => context.pop(),
        ),
        title: Text('Starter Pack'),
      ),
      body: _buildBody(context),
    );
  }
}
