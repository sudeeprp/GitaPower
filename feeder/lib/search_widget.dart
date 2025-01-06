import 'package:flutter/material.dart';

const searchBaseUrl = 'https://askys-token-572467571658.asia-south1.run.app/token/';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'What are you looking for?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Icon(Icons.search, size: 48),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 0,
              itemBuilder: (context, index) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
