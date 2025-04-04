import "package:cart_veg/bloc/cart/cart_bloc.dart";
import "package:cart_veg/bloc/categories/category_bloc.dart";
import "package:cart_veg/bloc/product/product_bloc.dart";
import "package:cart_veg/bloc/search/search_bloc.dart";
import "package:cart_veg/service/authentication_service.dart";
import "package:cart_veg/service/cart_service.dart";
import "package:cart_veg/service/current_product_service.dart";
import "package:cart_veg/service/home_page_service.dart";
import "package:cart_veg/service/search_service.dart";
import "package:get_it/get_it.dart";

final locator = GetIt.instance;

void setup() {
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => HomePageService());
  locator.registerLazySingleton(() => SearchService());
    locator.registerLazySingleton(() => CartService());
    locator.registerLazySingleton(() => CurrentProductService()); 
  locator.registerFactory<ProductBloc>(() => ProductBloc(
        homePageService: locator<HomePageService>(),
      ));

  locator.registerFactory<CategoryBloc>(() => CategoryBloc(
        homePageService: locator<HomePageService>(),
      ));
  locator.registerFactory<CartBloc>(
      () => CartBloc(cartService: locator<CartService>()));
      locator.registerFactory(() => SearchBloc(
        searchService: locator<SearchService>(),
      ));
        
}
