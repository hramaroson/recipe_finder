import 'package:chopper/chopper.dart';

import 'model_response.dart';
import 'recipe_model.dart';
import 'model_converter.dart';
import 'service_interface.dart';
import 'api_credentials.dart';

part 'recipe_service.chopper.dart';

// Use the following command in terminal to generate recipe_service.chopper.dart
// flutter pub run build_runner build --delete-conflicting-outputs
// To run every time the file changes, use:
// flutter pub run build_runner watch

@ChopperApi()
abstract class RecipeService extends ChopperService
    implements ServiceInterface {
  @override
  @Get(path: 'search')
  Future<Response<Result<APIRecipeQuery>>> queryRecipes(
    @Query('q') String query,
    @Query('from') int from,
    @Query('to') int to,
  );

  static RecipeService create() {
    final client = ChopperClient(
      baseUrl: Uri.parse(apiUrl),
      interceptors: [_addQuery, HttpLoggingInterceptor()],
      converter: ModelConverter(),
      errorConverter: const JsonConverter(),
      services: [
        _$RecipeService(),
      ],
    );
    return _$RecipeService(client);
  }
}

Request _addQuery(Request req) {
  final params = Map<String, dynamic>.from(req.parameters);
  params['app_id'] = apiId;
  params['app_key'] = apiKey;

  return req.copyWith(parameters: params);
}