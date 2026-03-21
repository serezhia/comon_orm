# comon_orm_otel

`comon_orm_otel` adds OpenTelemetry spans and metrics to `comon_orm` through middleware.

## Usage

```dart
import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_otel/comon_orm_otel.dart';

final adapter = MiddlewareDatabaseAdapter(
  adapter: InMemoryDatabaseAdapter(),
  middlewares: <DatabaseMiddleware>[
    OtelDatabaseMiddleware(dbSystem: 'sqlite'),
  ],
);
```