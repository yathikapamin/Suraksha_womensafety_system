import 'dart:math';

class MLClassifier {
  final Set<String> vocab = {};
  final Map<String, _ClassData> classes = {};
  int docCount = 0;

  List<String> tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  void train(List<Map<String, String>> data) {
    for (var item in data) {
      final text = item['text']!;
      final intent = item['intent']!;
      final words = tokenize(text);

      if (!classes.containsKey(intent)) {
        classes[intent] = _ClassData();
      }

      classes[intent]!.docCount++;
      docCount++;

      for (var word in words) {
        vocab.add(word);
        classes[intent]!.wordCounts[word] = (classes[intent]!.wordCounts[word] ?? 0) + 1;
        classes[intent]!.totalWords++;
      }
    }
  }

  Map<String, dynamic> predict(String text) {
    if (docCount == 0) return {'intent': 'NEUTRAL', 'confidence': 0.0};

    final words = tokenize(text);
    final scores = <String, double>{};

    final vocabSize = vocab.length;

    for (var intent in classes.keys) {
      final classData = classes[intent]!;
      final pClass = classData.docCount / docCount;
      double pDocGivenClassInt = log(pClass);

      for (var word in words) {
        final wordCount = classData.wordCounts[word] ?? 0;
        final pWordGivenClass = (wordCount + 1) / (classData.totalWords + vocabSize);
        pDocGivenClassInt += log(pWordGivenClass);
      }

      scores[intent] = pDocGivenClassInt;
    }

    // Softmax approximation
    double maxLogProb = scores.values.reduce(max);
    double sumExp = 0.0;
    final expScores = <String, double>{};

    for (var intent in scores.keys) {
      final val = exp(scores[intent]! - maxLogProb);
      expScores[intent] = val;
      sumExp += val;
    }

    String bestIntent = 'NEUTRAL';
    double bestConfidence = 0.0;

    for (var intent in expScores.keys) {
      final confidence = expScores[intent]! / sumExp;
      if (confidence > bestConfidence) {
        bestConfidence = confidence;
        bestIntent = intent;
      }
    }

    return {
      'intent': bestIntent,
      'confidence': bestConfidence,
    };
  }
}

class _ClassData {
  int docCount = 0;
  final Map<String, int> wordCounts = {};
  int totalWords = 0;
}
