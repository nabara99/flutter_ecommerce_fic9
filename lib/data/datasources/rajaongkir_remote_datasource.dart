import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../common/constants/variables.dart';
import '../models/responses/city_response_model.dart';
import '../models/responses/cost_response_model.dart';
import '../models/responses/province_response_model.dart';
import '../models/responses/subdistrict_response_model.dart';

class RajaongkirRemoteDatasource {
  Future<Either<String, ProvinceResponseModel>> getProvinces() async {
    final url = Uri.parse('https://pro.rajaongkir.com/api/province');
    final response = await http.get(
      url,
      headers: {
        'key': Variables.rajaongkirKey,
      },
    );
    if (response.statusCode == 200) {
      return right(ProvinceResponseModel.fromJson(response.body));
    } else {
      return left('Error');
    }
  }

  Future<Either<String, CityResponseModel>> getCities(String provinceId) async {
    final url =
        Uri.parse('https://pro.rajaongkir.com/api/city?province=$provinceId');
    final response = await http.get(url, headers: {
      'key': Variables.rajaongkirKey,
    });
    if (response.statusCode == 200) {
      return right(CityResponseModel.fromJson(response.body));
    } else {
      return left('Error');
    }
  }

  Future<Either<String, SubDistrictResponseModel>> getSubDistrict(
      String cityId) async {
    final url =
        Uri.parse('https://pro.rajaongkir.com/api/subdistrict?city=$cityId');
    final response = await http.get(url, headers: {
      'key': Variables.rajaongkirKey,
    });
    if (response.statusCode == 200) {
      return right(SubDistrictResponseModel.fromJson(response.body));
    } else {
      return left('Error');
    }
  }

  Future<Either<String, CostResponseModel>> getCost(
    String origin,
    String destination,
    String courier,
  ) async {
    final url = Uri.parse('https://pro.rajaongkir.com/api/cost');
    final response = await http.post(
      url,
      headers: {
        'key': Variables.rajaongkirKey,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'origin': origin,
        'originType': 'subdistrict',
        'destination': destination,
        'destinationType': 'subdistrict',
        'weight': '500',
        'courier': courier,
      },
    );
    if (response.statusCode == 200) {
      return right(CostResponseModel.fromJson(response.body));
    } else {
      return left('Error');
    }
  }
}
