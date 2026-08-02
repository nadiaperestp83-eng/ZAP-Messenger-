## 💖 Apoie este projeto

Se este projeto foi útil para você e deseja apoiar o desenvolvimento contínuo, considere fazer uma doação:

[![Doar com PayPal](https://img.shields.io/badge/Donate-PayPal-%2300457C?style=for-the-badge&logo=paypal&logoColor=white)](https://www.paypal.com/ncp/payment/4JVTRSHHZ682C)



# ZapZap 

Under development

A cross-platform (Android) Telegram client built with **Flutter** on top of
**[TDLib](https://core.telegram.org/tdlib)** via FFI, with a dense,
mobile-native messaging interface.

> **Disclaimer**
>
> Zap is a fork from Mithka is an **independent, unofficial** project. It is **not affiliated with,
> endorsed by, or connected to Telegram** in any way. "Telegram" is a trademark
> of its respective owner.
>
> It is also **not affiliated with, endorsed by, sponsored by, or otherwise
> connected to Tencent or QQ**. It does not use, include, copy, or redistribute
> any proprietary QQ assets. "Tencent" and "QQ" and their associated trademarks
> and assets belong to their respective owners.
>
> The app talks to Telegram's network through TDLib using your own Telegram API
> credentials. Use it at your own risk and in accordance with Telegram's
> [Terms of Service](https://telegram.org/tos) and API
> [Terms](https://core.telegram.org/api/terms).

## Availability



## The name

A play on small units of mass, by way of the Whatsapp:

- The name is Portuguese slang used for WhatsApp.


## What it is

ZapZap connects to **real Telegram** (your account, your chats) through TDLib and
presents it with a custom interface: chat list, conversations with live state,
reactions and stickers (including animated `.tgs`/`.webm`), voice notes, polls
and checklists, Telegram Communities, location sharing, contacts, profiles,
moments-style stories, settings, and a 1:1 call UI.

## Architecture

- **Flutter** UI (`lib/`), state via `provider` + `ChangeNotifier`.
- **TDLib** linked through Dart FFI (`lib/tdlib/`); the native `libtdjson`
  binary is downloaded/built per platform (see below) and is **not** committed.
- All theming is adaptive (light / dark); UI components are Cupertino/custom —
  no Material dialogs, snackbars, or switches.

## Building

You need your own **Telegram API credentials** (`api_id` / `api_hash`) from
<https://my.telegram.org>. They are read from a git-ignored
`lib/config/secrets.dart`:

```dart
class Secrets {
  static const int apiId = 123456;
  static const String apiHash = 'your_api_hash';
  static bool get isConfigured => apiId != 0 && apiHash.isNotEmpty;
}
```

The TDLib native library is prepared with helper scripts (output is git-ignored).

The Android
source-build script is kept for local fallback/debug builds.

```bash
# Android local fallback (per ABI) — produces android/app/src/main/jniLibs/<abi>/libtdjson.so
scripts/build-tdjson-android.sh arm64-v8a


```

Then run:

```bash
flutter pub get
flutter run            # on a connected device / simulator
```

Firebase Analytics is optional for local builds. If
`android/app/google-services.json` or `ios/Runner/GoogleService-Info.plist` is
missing (or is only an empty placeholder), the app builds and runs with
analytics disabled. Maintainers and release CI provide the real, git-ignored
configuration files automatically.

### Release signing (Android)

Release builds are signed with the project's upload key when
`android/key.properties` (and the referenced keystore) are present; otherwise a
debug signature is used. Neither the keystore nor `key.properties` is committed.

## Rules and License

Em complemento aos termos e condições da Licença Pública Geral GNU (GPLv3), aplicam-se as seguintes restrições adicionais relativas ao uso comercial:

PROIBIÇÃO DE USO COMERCIAL: Fica expressamente proibida a utilização, redistribuição, reempacotamento ou comercialização deste software (no todo ou em partes) para fins lucrativos, comerciais ou monetização direta/indireta (incluindo vendas em lojas de aplicativos com cobrança, inserção de anúncios pagos, ou oferecimento como serviço proprietário pago).

PERMISSÃO NÃO COMERCIAL (NON-COMMERCIAL): O fork, a cópia, a modificação e a redistribuição são totalmente livres e permitidos exclusivamente para fins não comerciais, educacionais, pessoais ou comunitários, desde que mantidos os créditos aos autores originais e que o código modificado permaneça sob esta mesma licença restritiva.

PREVALÊNCIA: Em caso de conflito entre os termos padrão da GPLv3 e esta Cláusula Adicional de Restrição Comercial, prevalecerá sempre a restrição de proibição de uso comercial descrita nos itens 1 e 2 acima.

## License & credits

ZapZap follow same Mithka is licensed under the [BSD 3-Clause License](LICENSE) and Rules

TDLib and the components under `third_party/` retain their own licenses. Mithka
ships no third-party app's proprietary assets or trademarks.

## Star History
<a href="https://www.star-history.com/?repos=iebb%2Fmithka&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=iebb/mithka&type=date&theme=dark&legend=top-left&sealed_token=1PtDobhZ9XXhT7wgN5YMBVDBa9coSe7MIPcmYtH78U0zAurRU1n2ZU9n_8HKCB7KYraJOet0tyGPTh3jXh_oq-RkR9els5W0T0EDz-_nvt0ce-n1AvOOKgljMdSc-FOc5j0X3RVcRmyyq0qoVZBdWqIPFKMpBvKO8yoRgRc9i9ck-r4-RmWM0FqWLjXG" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=iebb/mithka&type=date&legend=top-left&sealed_token=1PtDobhZ9XXhT7wgN5YMBVDBa9coSe7MIPcmYtH78U0zAurRU1n2ZU9n_8HKCB7KYraJOet0tyGPTh3jXh_oq-RkR9els5W0T0EDz-_nvt0ce-n1AvOOKgljMdSc-FOc5j0X3RVcRmyyq0qoVZBdWqIPFKMpBvKO8yoRgRc9i9ck-r4-RmWM0FqWLjXG" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=iebb/mithka&type=date&legend=top-left&sealed_token=1PtDobhZ9XXhT7wgN5YMBVDBa9coSe7MIPcmYtH78U0zAurRU1n2ZU9n_8HKCB7KYraJOet0tyGPTh3jXh_oq-RkR9els5W0T0EDz-_nvt0ce-n1AvOOKgljMdSc-FOc5j0X3RVcRmyyq0qoVZBdWqIPFKMpBvKO8yoRgRc9i9ck-r4-RmWM0FqWLjXG" />
 </picture>
</a>
