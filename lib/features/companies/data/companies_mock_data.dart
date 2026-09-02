import '../domain/entities/company.dart';
import '../domain/entities/company_package.dart';
import '../domain/entities/preset_company.dart';

/// Static mock/dummy data — no Drift/Supabase yet. Mirrors the balances
/// shown on the Home dashboard so numbers stay consistent across pages.
class CompaniesMockData {
  CompaniesMockData._();

  static List<Company> initialCompanies() => [
        const Company(
          id: 'airalo',
          name: 'Airalo eSIM',
          initials: 'AE',
          status: CompanyStatus.active,
          packages: [
            CompanyPackage(id: 'airalo-1', name: 'Regional 3GB', wholesaleCost: 18, retailPrice: 28),
            CompanyPackage(id: 'airalo-2', name: 'Global 5GB', wholesaleCost: 30, retailPrice: 45),
          ],
          operationsCount: 2,
          profitGenerated: 30,
          usagePercent: 10,
          consumed: 62,
          availableToSell: 538,
          owedToCompany: 0,
        ),
        const Company(
          id: 'jawwal',
          name: 'Jawwal',
          initials: 'J',
          pinned: true,
          status: CompanyStatus.active,
          packages: [
            CompanyPackage(id: 'jawwal-1', name: 'Weekly 1GB', wholesaleCost: 15, retailPrice: 25),
            CompanyPackage(id: 'jawwal-2', name: 'Monthly 5GB', wholesaleCost: 40, retailPrice: 60),
            CompanyPackage(id: 'jawwal-3', name: 'Monthly 10GB', wholesaleCost: 70, retailPrice: 100),
          ],
          operationsCount: 5,
          profitGenerated: 67,
          usagePercent: 8,
          consumed: 168,
          availableToSell: 1832,
          owedToCompany: 300,
        ),
        const Company(
          id: 'ooredoo',
          name: 'Ooredoo',
          initials: 'O',
          status: CompanyStatus.active,
          packages: [
            CompanyPackage(id: 'ooredoo-1', name: 'Weekly 2GB', wholesaleCost: 12, retailPrice: 20),
            CompanyPackage(id: 'ooredoo-2', name: 'Monthly 8GB', wholesaleCost: 35, retailPrice: 55),
          ],
          operationsCount: 4,
          profitGenerated: 37,
          usagePercent: 9,
          consumed: 84,
          availableToSell: 816,
          owedToCompany: 600,
        ),
        const Company(
          id: 'orange',
          name: 'Orange',
          initials: 'O',
          status: CompanyStatus.archived,
          packages: [
            CompanyPackage(id: 'orange-1', name: 'Monthly 3GB', wholesaleCost: 16, retailPrice: 26),
            CompanyPackage(id: 'orange-2', name: 'Monthly 6GB', wholesaleCost: 26, retailPrice: 40),
          ],
          operationsCount: 0,
          profitGenerated: 0,
        ),
      ];

  static const presetCompanies = [
    PresetCompany(
      name: 'Jawwal',
      initials: 'J',
      defaultPackages: [
        CompanyPackage(id: 'preset-jawwal-1', name: 'Weekly 1GB', wholesaleCost: 15, retailPrice: 25),
        CompanyPackage(id: 'preset-jawwal-2', name: 'Monthly 5GB', wholesaleCost: 40, retailPrice: 60),
        CompanyPackage(id: 'preset-jawwal-3', name: 'Monthly 10GB', wholesaleCost: 70, retailPrice: 100),
      ],
    ),
    PresetCompany(
      name: 'Ooredoo',
      initials: 'O',
      defaultPackages: [
        CompanyPackage(id: 'preset-ooredoo-1', name: 'Weekly 2GB', wholesaleCost: 12, retailPrice: 20),
        CompanyPackage(id: 'preset-ooredoo-2', name: 'Monthly 8GB', wholesaleCost: 35, retailPrice: 55),
      ],
    ),
    PresetCompany(
      name: 'Airalo eSIM',
      initials: 'AE',
      defaultPackages: [
        CompanyPackage(id: 'preset-airalo-1', name: 'Regional 3GB', wholesaleCost: 18, retailPrice: 28),
        CompanyPackage(id: 'preset-airalo-2', name: 'Global 5GB', wholesaleCost: 30, retailPrice: 45),
      ],
    ),
    PresetCompany(
      name: 'Holafly',
      initials: 'H',
      defaultPackages: [
        CompanyPackage(id: 'preset-holafly-1', name: 'Unlimited 7 Days', wholesaleCost: 25, retailPrice: 40),
        CompanyPackage(id: 'preset-holafly-2', name: 'Unlimited 15 Days', wholesaleCost: 40, retailPrice: 65),
      ],
    ),
    PresetCompany(
      name: 'Nomad eSIM',
      initials: 'NE',
      defaultPackages: [
        CompanyPackage(id: 'preset-nomad-1', name: 'Europe 3GB', wholesaleCost: 14, retailPrice: 22),
        CompanyPackage(id: 'preset-nomad-2', name: 'Europe 10GB', wholesaleCost: 28, retailPrice: 42),
      ],
    ),
    PresetCompany(
      name: 'Orange',
      initials: 'O',
      defaultPackages: [
        CompanyPackage(id: 'preset-orange-1', name: 'Monthly 3GB', wholesaleCost: 16, retailPrice: 26),
        CompanyPackage(id: 'preset-orange-2', name: 'Monthly 6GB', wholesaleCost: 26, retailPrice: 40),
      ],
    ),
  ];
}
