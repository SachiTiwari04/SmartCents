# SmartCents V3 Quick Start Guide

## Overview
SmartCents is a production-ready Flutter FinTech application with advanced hybrid stock prediction and personalized budget ML.

## Key Features

### 1. Hybrid Stock Prediction Engine
- **Location**: Market Screen (`lib/screens/market_screen.dart`)
- **How to Use**:
  1. Navigate to "Invest Hub" tab
  2. Enter a stock ticker (e.g., AAPL, GOOGL)
  3. View prediction with sentiment analysis
  4. Check news feed with sentiment tags
  5. Review 30-day historical chart

### 2. Personalized Budget Analysis
- **Location**: Legacy Log Screen (Transaction logging)
- **How to Use**:
  1. Log a transaction with amount and category
  2. ML classifier analyzes deviation from your average
  3. Receive classification: CRITICAL, HIGH, LOW, or STABLE
  4. Snackbar displays analysis result

### 3. Gamification System
- **Location**: Quests tab
- **Features**:
  - Complete challenges to earn reward points
  - Unlock "First Investor" badge
  - Track progress on active quests
  - View completed challenges

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│              SmartCents V3 Architecture             │
├─────────────────────────────────────────────────────┤
│                                                     │
│  UI Layer (Screens)                                │
│  ├─ MarketScreen (Hybrid Predictions)             │
│  ├─ PortfolioView (Dashboard)                     │
│  ├─ ChallengesView (Gamification)                 │
│  └─ LegacyTrackingView (Budget ML)                │
│                                                     │
│  ↓ (ref.watch/ref.read)                           │
│                                                     │
│  Provider Layer (State Management)                │
│  ├─ hybridPredictionProvider                      │
│  ├─ userStatsProvider                             │
│  ├─ budgetDeviationProvider                       │
│  ├─ transactionsProvider                          │
│  ├─ challengesProvider                            │
│  └─ stockApiServiceProvider                       │
│                                                     │
│  ↓                                                  │
│                                                     │
│  Service Layer (Business Logic)                   │
│  ├─ StockApiService (Predictions)                 │
│  ├─ FirestoreService (Database)                   │
│  ├─ AuthService (Authentication)                  │
│  └─ StockService (Legacy)                         │
│                                                     │
│  ↓                                                  │
│                                                     │
│  External Services                                │
│  ├─ Firebase Firestore (Database)                 │
│  ├─ Firebase Auth (Authentication)                │
│  └─ Mock APIs (Stock Data)                        │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## File Structure

```
lib/
├── main.dart                          # App entry point & main screens
├── models/
│   ├── stock_prediction_data.dart    # Hybrid prediction model
│   ├── transaction_model.dart        # Transaction model
│   ├── challenge_model.dart          # Challenge model
│   ├── stock_model.dart              # Stock model
│   └── user_model.dart               # User model
├── services/
│   ├── stock_api_service.dart        # Hybrid prediction service
│   ├── firestore_service.dart        # Database service
│   ├── auth_service.dart             # Authentication service
│   └── stock_service.dart            # Legacy stock service
├── providers/
│   ├── prediction_provider.dart      # Prediction system providers
│   ├── user_stats_provider.dart      # User statistics providers
│   ├── budget_ml_provider.dart       # Budget deviation ML providers
│   ├── transactions_provider.dart    # Transaction providers
│   ├── challenges_provider.dart      # Challenge providers
│   ├── stock_provider.dart           # Stock providers
│   ├── auth_provider.dart            # Auth providers
│   └── firestore_provider.dart       # Firestore providers
├── screens/
│   ├── market_screen.dart            # Hybrid prediction UI
│   ├── dashboard_screen.dart         # Portfolio view
│   ├── challenges_screen.dart        # Gamification
│   ├── transactions_screen.dart      # Transaction history
│   ├── auth_gate.dart                # Auth routing
│   └── main_screen.dart              # Main navigation
├── widgets/
│   ├── add_transaction_dialog.dart   # Transaction dialog
│   └── transaction_list.dart         # Transaction list widget
├── theme/
│   └── app_theme.dart                # Theme configuration
└── firebase_options.dart             # Firebase config
```

## Key Providers Reference

### Prediction System
```dart
// Watch current ticker prediction
final prediction = ref.watch(hybridPredictionProvider);

// Watch specific ticker prediction
final prediction = ref.watch(hybridPredictionFamilyProvider('AAPL'));

// Update current ticker
ref.read(currentTickerProvider.notifier).state = 'GOOGL';
```

### User Statistics
```dart
// Fetch user's personalized statistics
final stats = await ref.watch(userStatsProvider.future);

// Get specific category average
final avg = await ref.watch(categoryAverageProvider('Groceries').future);
```

### Budget ML
```dart
// Analyze transaction deviation
final result = await ref.watch(
  budgetDeviationProvider(('Groceries', 500.0)).future
);
// Returns: BudgetDeviationResult with classification
```

## Common Tasks

### Adding a New Stock to Watchlist
```dart
// In MarketScreen
ref.read(currentTickerProvider.notifier).state = 'TSLA';
// Prediction automatically fetches via hybridPredictionProvider
```

### Logging a Transaction
```dart
// In LegacyTrackingView
final transaction = TransactionModel(
  id: '',
  type: 'Expense',
  category: 'Groceries',
  amount: 250.0,
  date: DateTime.now(),
  notes: 'Weekly shopping',
);
await widget.addTransaction(transaction);
// ML classifier automatically analyzes deviation
```

### Completing a Challenge
```dart
// In ChallengesView
await completeChallenge(challenge);
// Reward points automatically incremented
// Achievement notification displayed
```

## Data Models

### StockPredictionData
```dart
StockPredictionData(
  ticker: 'AAPL',
  currentPrice: 150.25,
  predictedPrice: 155.80,
  sentimentScore: 0.75,
  riskIndication: 'BULLISH',
  newsFeed: [
    {'headline': 'Apple Reports Strong Earnings', 'sentiment': 'Positive'},
    // ... more news items
  ],
  historicalChartData: [100.0, 101.5, 102.3, ...], // 30 days
)
```

### BudgetDeviationResult
```dart
BudgetDeviationResult(
  classification: 'HIGH',
  message: 'Deviation: HIGH (Significant spike in Groceries)',
  deviationPercent: 35.0,
  isAnomalous: true,
)
```

### UserStats
```dart
UserStats(
  monthlyAverages: {
    'Groceries': 300.0,
    'Rent': 5000.0,
    'Entertainment': 150.0,
    // ... more categories
  },
  totalTransactions: 42,
  rewardPoints: 500,
  firstInvestor: true,
)
```

## Styling & Theme

### Colors
```dart
const Color neonCyan = Color(0xFF18FFFF);      // Primary accent
const Color neonPink = Color(0xFFFF4081);      // Secondary accent
const Color primaryBackground = Color(0xFF0D0D0D);  // Dark background
const Color surfaceColor = Color(0xFF1A1A1A);  // Card background
```

### Important: Use `.withOpacity()` NOT `.withValues(alpha:)`
```dart
// ✅ CORRECT
color: neonCyan.withOpacity(0.5)

// ❌ WRONG (deprecated)
color: neonCyan.withValues(alpha: 0.5)
```

## Debugging Tips

### Enable Riverpod Logging
```dart
// Add to main.dart
final container = ProviderContainer(
  observers: [RiverpodObserver()],
);
```

### Check Provider State
```dart
// In DevTools console
ref.refresh(hybridPredictionProvider);
```

### View Prediction Data
```dart
// In MarketScreen
predictionAsync.when(
  data: (prediction) {
    debugPrint('Ticker: ${prediction.ticker}');
    debugPrint('Sentiment: ${prediction.sentimentScore}');
    debugPrint('Risk: ${prediction.riskIndication}');
  },
  loading: () => debugPrint('Loading...'),
  error: (e, st) => debugPrint('Error: $e'),
);
```

## Performance Optimization

### Caching
- Riverpod automatically caches provider results
- Predictions cached until manually refreshed
- User stats cached for session duration

### Lazy Loading
- Historical chart data loaded on-demand
- News feed generated during prediction fetch
- User stats fetched only when needed

### Memory Management
- All models are immutable (const constructors)
- Proper disposal of TextEditingControllers
- StreamProvider handles subscription cleanup

## Testing

### Unit Test Example
```dart
test('High sentiment produces higher predicted price', () async {
  final service = StockApiService();
  final prediction = await service.fetchHybridPrediction('TEST');
  
  if (prediction.sentimentScore > 0.7) {
    expect(
      prediction.predictedPrice,
      greaterThan(prediction.currentPrice),
    );
  }
});
```

### Widget Test Example
```dart
testWidgets('Market screen displays prediction', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  expect(find.text('// HYBRID PREDICTION ENGINE'), findsOneWidget);
  expect(find.byType(LinearProgressIndicator), findsWidgets);
});
```

## Troubleshooting

### Issue: Prediction not updating
**Solution**: Ensure `currentTickerProvider` is updated before watching `hybridPredictionProvider`

### Issue: Budget ML showing wrong classification
**Solution**: Verify `userStatsProvider` is returning correct monthly averages

### Issue: News feed not displaying
**Solution**: Check that `newsFeed` list is populated in `StockApiService`

### Issue: Chart not rendering
**Solution**: Verify `historicalChartData` has at least 2 data points

## Production Deployment

### Pre-deployment Checklist
- [ ] Run `flutter analyze` (zero warnings)
- [ ] Run `flutter test` (all tests pass)
- [ ] Test on real devices (iOS + Android)
- [ ] Verify Firebase credentials
- [ ] Check API rate limits
- [ ] Review error handling
- [ ] Performance profiling complete

### Build Commands
```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release

# Web
flutter build web --release
```

## Support & Documentation

- **Refactoring Notes**: See `REFACTORING_NOTES.md`
- **Implementation Details**: See `IMPLEMENTATION_SUMMARY.md`
- **API Documentation**: See inline code comments
- **Issue Tracking**: Use GitHub Issues

## Version History

### V3.0.0 (Current)
- ✅ Hybrid Stock Prediction System
- ✅ Personalized Budget ML
- ✅ Riverpod Architecture Enforcement
- ✅ Production Code Cleanup
- ✅ Zero Deprecated APIs

### V2.0.0 (Previous)
- Basic transaction tracking
- Challenge system
- Stock watchlist

### V1.0.0 (Initial)
- MVP with basic features

---

**Last Updated**: November 27, 2025
**Status**: Production Ready
**Maintainer**: Development Team
