import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:inspired_senior_care_app/data/models/category.dart';
import 'package:inspired_senior_care_app/data/repositories/database/database_repository.dart';
import 'package:inspired_senior_care_app/data/repositories/storage/storage_repository.dart';
import 'package:meta/meta.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  List<Category> categoryList = [];
  final DatabaseRepository _databaseRepository;
  final StorageRepository _storageRepository;
  StreamSubscription? _databaseSubscription;

  CategoriesBloc(
      {required DatabaseRepository databaseRepository,
      required StorageRepository storageRepository})
      : _databaseRepository = databaseRepository,
        _storageRepository = storageRepository,
        super(CategoriesLoading()) {
    on<LoadCategories>(_onCategoriesLoaded);
    on<UpdateCategories>(_onCategoriesUpdated);
  }

  void _onCategoriesLoaded(
      LoadCategories event, Emitter<CategoriesState> emit) async {
    _databaseSubscription?.cancel();
    categoryList.clear();
    List<String> cardImages = await _storageRepository.getCategoryCovers();
    await emit.forEach(
      _databaseRepository.getCategories(),
      onData: (List<Category>? categories) {
        print('Got ${categories!.length} categories from Firestore***');
        return CategoriesLoaded(
            categories: categories, categoryImageUrls: cardImages);
      },
      onError: (error, stackTrace) {
        return CategoriesFailed();
      },
    );
  }

  void _onCategoriesUpdated(
      UpdateCategories event, Emitter<CategoriesState> emit) {
    add(LoadCategories());
  }
}
