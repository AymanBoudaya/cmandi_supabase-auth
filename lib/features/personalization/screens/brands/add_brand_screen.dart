import 'package:caferesto/features/shop/controllers/brand_controller.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/image_strings.dart';

class AddBrandScreen extends StatelessWidget {
  AddBrandScreen({Key? key}) : super(key: key);

  final BrandController _brandController = Get.put(BrandController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text('Ajouter un établissement'),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _brandController.formKey,
          child: Column(
            children: [
              Obx(() {
                final imageFile = _brandController.pickedImage.value;
                return GestureDetector(
                  onTap: _brandController.pickImage,
                  child: imageFile != null
                      ? Image.file(
                          imageFile,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          TImages.coffee,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                );
              }),
              SizedBox(height: 8),
              TextButton.icon(
                onPressed: _brandController.pickImage,
                icon: Icon(Icons.image),
                label: Text('Choisir une image'),
              ),
              TextFormField(
                controller: _brandController.nameController,
                decoration:
                    InputDecoration(labelText: "Nom de l'établissement"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: AppSizes.spaceBtwInputFields,
              ),
              Obx(() => CheckboxListTile(
                    title: Text('Etablissement en vedette'),
                    value: _brandController.isFeatured.value,
                    onChanged: (val) {
                      _brandController.isFeatured.value = val ?? false;
                    },
                  )),
              SizedBox(height: 20),
              Obx(() => _brandController.isLoading.value
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _brandController.addBrand,
                        child: Text('Ajouter Etablissement'),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
