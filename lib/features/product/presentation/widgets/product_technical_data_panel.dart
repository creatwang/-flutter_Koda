import 'package:flutter/material.dart';
import 'package:groe_app_pad/features/product/models/product_detail_dto.dart';

class ProductTechnicalDataPanel extends StatelessWidget {
  const ProductTechnicalDataPanel({
    required this.referenceCode,
    required this.params,
    super.key,
  });

  final String referenceCode;
  final List<ProductParam> params;

  @override
  Widget build(BuildContext context) {
    final validParams = params
        .where(
          (item) =>
              (item.name ?? '').trim().isNotEmpty &&
              (item.value ?? '').trim().isNotEmpty,
        )
        .toList(growable: false);
    if (validParams.isEmpty) {
      return const SizedBox.shrink();
    }

    final splitIndex = (validParams.length / 2).ceil();
    final leftParams = validParams.take(splitIndex).toList(growable: false);
    final rightParams = validParams.skip(splitIndex).toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5B554E).withValues(alpha: 0.62),
            const Color(0xFF23262B).withValues(alpha: 0.70),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Technical Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Ref. $referenceCode',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return _TechnicalColumn(params: validParams);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TechnicalColumn(params: leftParams)),
                  const SizedBox(width: 80),
                  Expanded(child: _TechnicalColumn(params: rightParams)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TechnicalColumn extends StatelessWidget {
  const _TechnicalColumn({required this.params});

  final List<ProductParam> params;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: params.map((item) {
        final name = (item.name ?? '').trim();
        final value = (item.value ?? '').trim();
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }
}
