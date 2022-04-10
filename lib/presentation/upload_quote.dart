import 'package:dtf_web/constants/app_string.dart';
import 'package:dtf_web/model/main_category.dart';
import 'package:dtf_web/model/quote.dart';
import 'package:dtf_web/presentation/widgets/kText.dart';
import 'package:dtf_web/state_provider/firestore_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadQuote extends StatefulWidget {
  const UploadQuote({Key? key}) : super(key: key);

  @override
  State<UploadQuote> createState() => _UploadQuoteState();
}

class _UploadQuoteState extends State<UploadQuote> {
  ValueNotifier<MainCategory> mainCategoryNotifier =
      ValueNotifier(const MainCategory(categoryId: '', mainCategory: ''));
  int trackIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final authorEditController = TextEditingController();
  final quoteEditController = TextEditingController();

  @override
  void initState() {
    context.read<FireStoreProvider>().getListOfMainCategory((e) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              const KText(AppString.addQuote,
                  fontSize: 34.0, fontWeight: FontWeight.bold),
              ValueListenableBuilder<MainCategory>(
                valueListenable: mainCategoryNotifier,
                builder: (context, value, child) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'Select Category',
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide:
                            BorderSide(width: 1, color: Colors.transparent),
                      ),
                    ),
                    isEmpty: value.mainCategory.isEmpty,
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<MainCategory>(
                      focusColor: Colors.transparent,
                      value: value.mainCategory.isEmpty ? null : value,
                      isDense: true,
                      items: context
                          .watch<FireStoreProvider>()
                          .mainCategoryList
                          .map((e) => DropdownMenuItem(
                              child: KText(e.mainCategory), value: e))
                          .toList(),
                      onChanged: (val) async {
                        mainCategoryNotifier.value = val!;
                        await context
                            .read<FireStoreProvider>()
                            .getSubCategoryList((e) {}, id: val.categoryId);
                      },
                    )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Wrap(
                  spacing: 15.0,
                  runSpacing: 10,
                  children: context
                      .watch<FireStoreProvider>()
                      .subCategoryList
                      .asMap()
                      .map((i, element) => MapEntry(
                          i,
                          ChoiceChip(
                            label: Text(element),
                            onSelected: (v) {
                              setState(() {
                                trackIndex = i;
                              });
                            },
                            selected: i == trackIndex,
                          )))
                      .values
                      .toList(),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///author
                    TextFormField(
                      controller: authorEditController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: AppString.authorName,
                        fillColor: Colors.grey[200],
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 26.0),
                    TextFormField(
                      controller: quoteEditController,
                      // The validator receives the text that the user has entered.
                      decoration: InputDecoration(
                        filled: true,
                        hintText: AppString.quote,
                        fillColor: Colors.grey[200],
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide:
                              BorderSide(width: 1, color: Colors.transparent),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<MainCategory>(
                      valueListenable: mainCategoryNotifier,
                      builder: (_, value, child) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ElevatedButton(
                              onPressed: !(value.mainCategory.isEmpty&&value.mainCategory.isEmpty)?() {
                                final quoteModel = QuoteModel(author: authorEditController.text, quote: quoteEditController.text);

                                if (_formKey.currentState!.validate()) {
                                  // context.read<FireStoreProvider>().upLoadQuote(
                                  //     (e) {},
                                  //     collection: context
                                  //         .read<FireStoreProvider>()
                                  //         .subCategoryList[trackIndex],
                                  //     map: quoteModel.toMap());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Processing Data')),
                                  );
                                }
                              }:null,
                              child: const Text('Submit'),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

