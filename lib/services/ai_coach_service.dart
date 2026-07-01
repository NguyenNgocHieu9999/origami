import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/origami_models.dart';

class AiCoachService {
  const AiCoachService();

  Future<String> ask({
    required String question,
    required OrigamiModel? model,
    required List<OrigamiStep> steps,
    required String? apiKey,
    required String provider,
  }) async {
    final cleanQuestion = question.trim();
    if (cleanQuestion.isEmpty) {
      return 'Bạn hãy nhập bước đang bị kẹt hoặc điều muốn cải thiện, AI Coach sẽ gợi ý cách xử lý.';
    }

    final cleanKey = apiKey?.trim() ?? '';
    final activeProvider = (provider == 'pollinations' || cleanKey.isEmpty)
        ? 'pollinations'
        : provider;

    Object? lastError;

    try {
      String answer = '';
      if (activeProvider == 'pollinations') {
        answer = await _askPollinations(
          question: cleanQuestion,
          model: model,
          steps: steps,
        );
      } else if (activeProvider == 'gemini') {
        answer = await _askGemini(
          question: cleanQuestion,
          model: model,
          steps: steps,
          apiKey: cleanKey,
        );
      } else if (activeProvider == 'groq') {
        answer = await _askGroq(
          question: cleanQuestion,
          model: model,
          steps: steps,
          apiKey: cleanKey,
        );
      } else if (activeProvider == 'openrouter') {
        answer = await _askOpenRouter(
          question: cleanQuestion,
          model: model,
          steps: steps,
          apiKey: cleanKey,
        );
      }

      if (answer.trim().isNotEmpty) {
        return answer.trim();
      }
    } catch (e) {
      lastError = e;
      if (activeProvider != 'pollinations') {
        try {
          final fallbackAnswer = await _askPollinations(
            question: cleanQuestion,
            model: model,
            steps: steps,
          );
          if (fallbackAnswer.trim().isNotEmpty) {
            return '${fallbackAnswer.trim()}\n\n(Lưu ý: Không kết nối được tới $provider. Đang tự động phản hồi qua cấu hình dự phòng Pollinations AI)';
          }
        } catch (err) {
          lastError = err;
        }
      }
    }

    final errorDetail = lastError != null ? '\n(Chi tiết lỗi: $lastError)' : '';
    return '${_localAnswer(cleanQuestion, model, steps)}\n\nKhông gọi được AI online$errorDetail nên app đang dùng hướng dẫn cục bộ.';
  }

  Future<String> _askPollinations({
    required String question,
    required OrigamiModel? model,
    required List<OrigamiStep> steps,
  }) async {
    final modelText = model == null
        ? 'Chưa chọn mẫu cụ thể.'
        : 'Mẫu: ${model.title}, độ khó ${model.difficulty}/4, thời gian ${model.minutes} phút.';
    final stepText = steps
        .map(
          (step) =>
              'Bước ${step.stepOrder}: ${step.title} - ${step.instruction}',
        )
        .join('\n');

    final systemPrompt = 'Bạn là AI hướng dẫn gấp giấy origami cho sinh viên. Trả lời tiếng Việt, ngắn gọn, theo từng gạch đầu dòng thực hành được. '
        '\n$modelText\nCác bước hiện có:\n$stepText';

    final url = 'https://text.pollinations.ai/${Uri.encodeComponent(question)}?system=${Uri.encodeComponent(systemPrompt)}';
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Pollinations request failed: ${response.statusCode}');
    }
    return response.body;
  }

  Future<String> _askGemini({
    required String question,
    required OrigamiModel? model,
    required List<OrigamiStep> steps,
    required String apiKey,
  }) async {
    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/gemini-1.5-flash:generateContent',
      {'key': apiKey},
    );

    final userPrompt = _buildPrompt(model, steps, question);

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text':
                        'Bạn là AI hướng dẫn gấp giấy origami cho sinh viên. '
                        'Trả lời tiếng Việt, ngắn gọn, theo từng gạch đầu dòng thực hành được. '
                        '\n$userPrompt',
                  },
                ],
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 18));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('AI request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    final content =
        candidates?.firstOrNull?['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    return (parts?.firstOrNull?['text'] as String?) ?? '';
  }

  Future<String> _askGroq({
    required String question,
    required OrigamiModel? model,
    required List<OrigamiStep> steps,
    required String apiKey,
  }) async {
    final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final systemPrompt = 'Bạn là AI hướng dẫn gấp giấy origami cho sinh viên. Trả lời tiếng Việt, ngắn gọn, theo từng gạch đầu dòng thực hành được.';
    final userPrompt = _buildPrompt(model, steps, question);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'llama-3.1-8b-instant',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Groq request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    final message = choices?.firstOrNull?['message'] as Map<String, dynamic>?;
    return (message?['content'] as String?) ?? '';
  }

  Future<String> _askOpenRouter({
    required String question,
    required OrigamiModel? model,
    required List<OrigamiStep> steps,
    required String apiKey,
  }) async {
    final uri = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final systemPrompt = 'Bạn là AI hướng dẫn gấp giấy origami cho sinh viên. Trả lời tiếng Việt, ngắn gọn, theo từng gạch đầu dòng thực hành được.';
    final userPrompt = _buildPrompt(model, steps, question);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'HTTP-Referer': 'https://github.com/example/origami',
        'X-Title': 'Origami Mentor',
      },
      body: jsonEncode({
        'model': 'google/gemma-2-9b-it:free',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('OpenRouter request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    final message = choices?.firstOrNull?['message'] as Map<String, dynamic>?;
    return (message?['content'] as String?) ?? '';
  }

  String _buildPrompt(OrigamiModel? model, List<OrigamiStep> steps, String question) {
    final modelText = model == null
        ? 'Chưa chọn mẫu cụ thể.'
        : 'Mẫu: ${model.title}, độ khó ${model.difficulty}/4, thời gian ${model.minutes} phút.';
    final stepText = steps
        .map(
          (step) =>
              'Bước ${step.stepOrder}: ${step.title} - ${step.instruction}',
        )
        .join('\n');
    return '$modelText\nCác bước hiện có:\n$stepText\nCâu hỏi: $question';
  }

  String _localAnswer(
    String question,
    OrigamiModel? model,
    List<OrigamiStep> steps,
  ) {
    final lower = question.toLowerCase();
    final selected = model;
    final modelName = selected?.title ?? 'mẫu đang chọn';
    final currentStep = _matchStep(lower, steps);

    final buffer = StringBuffer()
      ..writeln('Gợi ý cho $modelName:')
      ..writeln(
        '- Đặt giấy thật phẳng, miết nếp từ tâm ra ngoài để tránh lệch.',
      )
      ..writeln(
        '- Làm chậm ở nếp đảo hoặc lớp giấy dày; mở lại nếp trước khi ép mạnh.',
      );

    if (currentStep != null) {
      buffer
        ..writeln(
          '- Với ${currentStep.title.toLowerCase()}: ${currentStep.instruction}',
        )
        ..writeln('- Mẹo kiểm tra: ${currentStep.tip}');
    }

    if (lower.contains('rách') || lower.contains('nhăn')) {
      buffer.writeln(
        '- Nếu giấy rách/nhăn, giảm lực miết và đổi sang giấy mỏng hơn khoảng 70-90 gsm.',
      );
    }
    if (lower.contains('lệch') ||
        lower.contains('không đều') ||
        lower.contains('cân')) {
      buffer.writeln(
        '- Nếu hai bên lệch, mở về nếp trung tâm gần nhất rồi căn lại hai góc đối xứng trước.',
      );
    }
    if (lower.contains('hoàn thành') || lower.contains('đánh giá')) {
      buffer.writeln(
        '- Business rule của app: chỉ ghi hoàn thành khi đã tick đủ mọi bước và rating từ 3 sao trở lên.',
      );
    }

    buffer.writeln(
      '- Sau khi ổn, lưu nhật ký kèm rating để mở huy hiệu tiến độ.',
    );
    return buffer.toString().trim();
  }

  OrigamiStep? _matchStep(String lowerQuestion, List<OrigamiStep> steps) {
    for (final step in steps) {
      if (lowerQuestion.contains('${step.stepOrder}') ||
          lowerQuestion.contains(step.title.toLowerCase())) {
        return step;
      }
    }
    return null;
  }
}
