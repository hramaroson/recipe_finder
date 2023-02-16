import 'dart:developer';
import 'package:http/http.dart';

import 'api_credentials.dart';

class RecipeService{
  Future getData(String url) async{
     final response = await get(Uri.parse(url));
     if(response.statusCode == 200){
        return response.body;
     }
     else {
      log(response.body);
     }
  }

  Future<dynamic> getRecipes(String query, int from, int to) async{
    final recipeData = await getData('$apiUrl?'
      'app_id=$apiId&app_key=$apiKey&q=$query&from=$from&to=$to');

    return recipeData;
  }
}