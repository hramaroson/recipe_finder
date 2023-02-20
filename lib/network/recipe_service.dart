import 'package:chopper/chopper.dart';

import 'model_response.dart';
import 'recipe_model.dart';
import 'model_converter.dart';
import 'api_credentials.dart';

@ChopperApi()
abstract class RecipeService extends ChopperService{
  @Get(path: 'search')
  Future<Response<Result<APIRecipeQuery>>> queryRecipes(
    @Query('q') String query, @Query('from') int from, 
    @Query('to') int to);
}

