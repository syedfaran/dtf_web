import 'package:dtf_web/model/main_category.dart';
import 'package:dtf_web/presentation/widgets/kText.dart';
import 'package:dtf_web/state_provider/firestore_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CreateCategoryAndSubCategory extends StatefulWidget {
  const CreateCategoryAndSubCategory({Key? key}) : super(key: key);

  @override
  State<CreateCategoryAndSubCategory> createState() =>
      _CreateCategoryAndSubCategoryState();
}

class _CreateCategoryAndSubCategoryState
    extends State<CreateCategoryAndSubCategory> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _categoryEditingController;
  late TextEditingController _subCategoryEditingController;
  ValueNotifier<MainCategory> mainCategoryNotifier =
      ValueNotifier(const MainCategory(categoryId: '', mainCategory: ''));

  @override
  void initState() {
    _categoryEditingController = TextEditingController();
    _subCategoryEditingController = TextEditingController();
    context.read<FireStoreProvider>().getListOfMainCategory((e) {});
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const KText('Add Category'),
          TextFormField(
            controller: _categoryEditingController,
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await context.read<FireStoreProvider>().addCategory((e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error Data $e')));
                  }, string: _categoryEditingController.text);
                }
              },
              child: const Text('Submit'),
            ),
          ),
          const KText('Add SubCategory'),
          ValueListenableBuilder<MainCategory>(
            valueListenable: mainCategoryNotifier,
            builder: (context, value, child) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal)),
                  hintText: 'hintText',
                ),
                isEmpty: value.mainCategory.isEmpty,
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<MainCategory>(
                  value: value.mainCategory.isEmpty ? null : value,
                  isDense: true,
                  items: context
                      .watch<FireStoreProvider>()
                      .mainCategoryList
                      .map((e) => DropdownMenuItem(
                          child: KText(e.mainCategory), value: e))
                      .toList(),
                  onChanged: (val) {
                    mainCategoryNotifier.value = val!;
                  },
                )),
              ),
            ),
          ),
          TextFormField(
            controller: _subCategoryEditingController,
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await context.read<FireStoreProvider>().addSubCategory((e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error Data $e')));
                  },
                      string: _subCategoryEditingController.text,
                      id: mainCategoryNotifier.value.categoryId);
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
