import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/stocks/data/dto/stock_json.dart';
import 'package:saveapenny/features/stocks/domain/stock_news.dart';

part 'stock_news_response.freezed.dart';
part 'stock_news_response.g.dart';

@freezed
abstract class TickerSentimentResponse with _$TickerSentimentResponse {
  const factory TickerSentimentResponse({
    required String ticker,
    String? relevanceScore,
    @JsonKey(name: 'tickerSentimentScore', fromJson: stockNumOrNull)
    num? tickerSentimentScore,
    String? tickerSentimentLabel,
  }) = _TickerSentimentResponse;

  factory TickerSentimentResponse.fromJson(Map<String, dynamic> json) =>
      _$TickerSentimentResponseFromJson(json);
}

@freezed
abstract class NewsArticleResponse with _$NewsArticleResponse {
  const factory NewsArticleResponse({
    required String title,
    required String url,
    String? timePublished,
    String? summary,
    String? source,
    @JsonKey(fromJson: stockNumOrNull) num? overallSentimentScore,
    String? overallSentimentLabel,
    @Default(<TickerSentimentResponse>[])
    List<TickerSentimentResponse> tickerSentiment,
  }) = _NewsArticleResponse;

  factory NewsArticleResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsArticleResponseFromJson(json);
}

@freezed
abstract class StockNewsResponse with _$StockNewsResponse {
  const factory StockNewsResponse({
    required int items,
    required List<NewsArticleResponse> articles,
  }) = _StockNewsResponse;

  factory StockNewsResponse.fromJson(Map<String, dynamic> json) =>
      _$StockNewsResponseFromJson(json);
}

extension TickerSentimentResponseX on TickerSentimentResponse {
  StockTickerSentiment toDomain() {
    return StockTickerSentiment(
      ticker: ticker,
      relevanceScore: relevanceScore,
      sentimentScore: tickerSentimentScore,
      sentimentLabel: tickerSentimentLabel,
    );
  }
}

extension NewsArticleResponseX on NewsArticleResponse {
  StockNewsArticle toDomain() {
    return StockNewsArticle(
      title: title,
      url: url,
      timePublished: timePublished,
      summary: summary,
      source: source,
      overallSentimentScore: overallSentimentScore,
      overallSentimentLabel: overallSentimentLabel,
      tickerSentiment: tickerSentiment
          .map((item) => item.toDomain())
          .toList(growable: false),
    );
  }
}

extension StockNewsResponseX on StockNewsResponse {
  StockNews toDomain() {
    return StockNews(
      items: items,
      articles: articles.map((item) => item.toDomain()).toList(growable: false),
    );
  }
}
