import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_news.freezed.dart';

@freezed
abstract class StockTickerSentiment with _$StockTickerSentiment {
  const factory StockTickerSentiment({
    required String ticker,
    String? relevanceScore,
    num? sentimentScore,
    String? sentimentLabel,
  }) = _StockTickerSentiment;
}

@freezed
abstract class StockNewsArticle with _$StockNewsArticle {
  const factory StockNewsArticle({
    required String title,
    required String url,
    String? timePublished,
    String? summary,
    String? source,
    num? overallSentimentScore,
    String? overallSentimentLabel,
    required List<StockTickerSentiment> tickerSentiment,
  }) = _StockNewsArticle;
}

@freezed
abstract class StockNews with _$StockNews {
  const factory StockNews({
    required int items,
    required List<StockNewsArticle> articles,
  }) = _StockNews;
}
