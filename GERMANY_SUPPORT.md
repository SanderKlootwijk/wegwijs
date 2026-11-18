# Germany and France Support for Wegwijs

This fork adds fuel prices for German stations via the Tankerkönig API
(data from the Markttransparenzstelle für Kraftstoffe, MTS-K, CC BY 4.0)
and for French stations via the official open data feed
"Prix des carburants en France – Flux instantané – v2" (data.economie.gouv.fr,
Licence Ouverte 2.0, no API key needed).

## How it works

Based on the current location the app picks the data source:

- **Netherlands** → ANWB API (original behaviour)
- **Germany** → Tankerkönig API (own key required)
- **France** → data.economie.gouv.fr (no key)
- **German–French border** (e.g. Strasbourg/Kehl) → both, merged into one list
- **Other countries** → ANWB API (fallback)
- **Electric** → Open Charge Map (unchanged)

## API key (entered in the app)

Tankerkönig issues free API keys per person, so no key is shipped with the app.

1. Request a free key at https://onboarding.tankerkoenig.de
2. In Wegwijs open **Settings → Fuel prices Germany** and paste the key
3. The fuel list reloads automatically

Without a key, the fuel list stays empty for locations in Germany.

## Fuel type mapping

| Wegwijs         | Tankerkönig (DE) | France        |
|-----------------|------------------|---------------|
| Euro 95 (E10)   | `e10`            | `e10_prix`    |
| Euro 98 (E5)    | `e5`             | `sp98_prix`   |
| Diesel (B7)     | `diesel`         | `gazole_prix` |
| LPG             | not available    | `gplc_prix`   |

Notes:
- The Tankerkönig search radius is limited to 25 km.
- The French feed contains no station names; stations are shown as "Fuel station" with address and town.
- Neither source provides price tiers, so LOW/AVG/HIGH are computed relative to the stations found.

## Testing

1. Enter your Tankerkönig key in Settings
2. Set the location to a German town (e.g. Laichingen, Westerheim, Merklingen)
3. Open the fuel page – German stations with current prices should appear
4. For France, set the location to e.g. Strasbourg – no key needed

## License

This modification keeps the original GPLv3 license of Wegwijs.
Fuel price data: MTS-K via Tankerkönig, CC BY 4.0; France: data.economie.gouv.fr, Licence Ouverte 2.0.
