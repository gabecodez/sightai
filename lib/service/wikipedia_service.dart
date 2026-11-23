import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WikipediaResult {
  const WikipediaResult({
    required this.title,
    required this.extract,
    required this.articleUrl,
  });

  final String title;
  final String extract;
  final Uri articleUrl;
}

class WikipediaService {
  WikipediaService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WikipediaResult?> findForDescription(String description) async {
    final subject = await _identifySubject(description);
    if (subject == null) return null;
    return _searchArticle(subject);
  }

  Future<String?> _identifySubject(String description) async {
    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-3-flash-preview',
      );
      final response = await model.generateContent([
        Content.text(
          'Based only on this image description, identify one recognizable '
          'Wikipedia-worthy proper subject if it is stated confidently.'
          'Return strictly valid JSON with no markdown. Use exactly this shape:'
          '{"subject":"Article title","confidence":"high"}'
          'or {"subject":null,"confidence":"low"}.'
          'Do not infer locations or objects not explicit in the description. '
          'Do not return categories or generic things such as "building", '
          '"animal", or "person".'
          'Description: $description',
        ),
      ]);

      final raw = response.text?.trim();
      if (raw == null || raw.isEmpty) return null;

      final jsonStart = raw.indexOf('{');
      final jsonEnd = raw.lastIndexOf('}');
      if (jsonStart < 0 || jsonEnd <= jsonStart) return null;
      final decoded = jsonDecode(raw.substring(jsonStart, jsonEnd + 1));
      if (decoded is! Map) return null;

      final confidence = decoded['confidence'];
      final subject = decoded['subject'];
      if (confidence != 'high' || subject is! String) return null;

      final cleaned = subject.trim();
      if (cleaned.isEmpty || cleaned.length > 120) return null;
      return cleaned;
    } catch (error) {
      debugPrint('Wikipedia subject identification error: $error');
      return null;
    }
  }

  Future<WikipediaResult?> _searchArticle(String subject) async {
    try {
      final searchUri = Uri.https('en.wikipedia.org', '/w/api.php', {
        'action': 'query',
        'list': 'search',
        'srsearch': subject,
        'srlimit': '5',
        'format': 'json',
      });
      final searchResponse = await _client
          .get(searchUri)
          .timeout(const Duration(seconds: 8));
      if (searchResponse.statusCode != 200) return null;

      final searchJson = jsonDecode(searchResponse.body);
      final search = searchJson['query']?['search'];
      if (search is! List) return null;

      final normalizedSubject = _normalize(subject);
      String? matchedTitle;
      for (final item in search) {
        if (item is! Map || item['title'] is! String) continue;
        final title = item['title'] as String;
        if (_normalize(title) == normalizedSubject) {
          matchedTitle = title;
          break;
        }
      }
      if (matchedTitle == null) return null;

      final extractUri = Uri.https('en.wikipedia.org', '/w/api.php', {
        'action': 'query',
        'prop': 'extracts',
        'exintro': '1',
        'explaintext': '1',
        'titles': matchedTitle,
        'redirects': '1',
        'format': 'json',
        'formatversion': '2',
      });
      final extractResponse = await _client
          .get(extractUri)
          .timeout(const Duration(seconds: 8));
      if (extractResponse.statusCode != 200) return null;

      final extractJson = jsonDecode(extractResponse.body);
      final pages = extractJson['query']?['pages'];
      if (pages is! List || pages.isEmpty) return null;

      final page = pages.first;
      if (page is! Map || page['title'] is! String) return null;

      final title = page['title'] as String;
      final extract = page['extract'];
      if (extract is! String) return null;

      final cleanedExtract = extract.trim();
      if (cleanedExtract.isEmpty) return null;

      final shortExtract = cleanedExtract.length <= 800
          ? cleanedExtract
          : '${cleanedExtract.substring(0, 797).trimRight()}...';

      final articleUrl = Uri.https(
        'en.wikipedia.org',
        '/wiki/${Uri.encodeComponent(title.replaceAll(' ', '_'))}',
      );
      return WikipediaResult(
        title: title,
        extract: shortExtract,
        articleUrl: articleUrl,
      );
    } catch (error) {
      debugPrint('Wikipedia lookup error: $error');
      return null;
    }
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  void dispose() => _client.close();
}
