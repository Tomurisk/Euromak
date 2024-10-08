# Windows
## MSKLC
Naudoti pagrindinį naudotoją
* Parsisiųsti [*MSKLC*](https://web.archive.org/web/20140904034703/http://download.microsoft.com/download/1/1/8/118aedd2-152c-453f-bac9-5dd8fb310870/MSKLC.exe)
* Įdiegti *MSKLC*
* Atidaryti `cm-dh_us.klc` failą su *MSKLC*. Meniu juostoje paspausti *Project* > *Build DLL and Setup Package*
* Įdiegti `cm-dh_us_amd64.msi` ir perkrauti kompiuterį.
* Perkrovus kompiuterį, nueiti į *Settings* > *Time & Language* > *Language* > *English (United States)* > *Options* > *US (QWERTY)* > Remove

Naudoti paprastą naudotoją
* Parsisiųsti [*AutoHotkey* ](https://community.chocolatey.org/packages/autohotkey.portable/1.1.34.04)
* Nueiti į `Failai\Euromak files`
* Atidaryti *Ahk2Exe* programą, joje pasirinkti `euromak_lt_ro.ahk` kaip *Source* ir `C:\Users\User\Programs\Euromak\euromak_lt_ro.exe` kaip *Destination*. Toliau spausti *Convert*. (Žr. [[#Naujausia versija]])
* Nukopijuoti *ICO* failo formatų ikonas į tą patį aplanką, kur yra „Euromak“ vykdomasis failas.
* Pridėti 
``` 
  cmd /c start "" /high "C:\Users\User\Programs\Euromak\euromak_lt_ro.exe"
  ```
  prie `startup.bat`.
## Svarbu!
Saugiai išsisaugoti *MSKLC* konvertuotus diegimo failus. Tai nėra tobulai sukurta programa, todėl išdiegiant klaviatūros išsidėstymą kitu būdu nei atidarant diegimo failą `setup.exe` ir pasirenkant *Select whether you want to repair or remove \[išsidėstymas\]. > Remove the keyboard layout.* bus netvarkingai palikti registro įrašai.

[Šaltinis](https://msklc-guide.github.io/) | [Šaltinis (archyvuotas)](https://web.archive.org/web/20240316190930/https://msklc-guide.github.io/)
> **06: Uninstalling layouts**
>
> Technically, you can see all your layouts in Window's Apps/Programs-list. However, uninstalling the layouts from there can lead to them being bricked in place. That means, the layout is no longer usable, but some data of it still haunts your harddrive. The effects are annoying at most: the layout won't disappear from the Apps/Programs-list, and you won't be able to install a new layout with the same name.
>
> The healthier way to uninstall layouts is to keep the _.msi_ and _.exe_ you got when you installed your layout. If you wish to uninstall the layout, just execute the _.exe_ file again, and you should be done. This probably won't work after you tried to do it on the Apps/Programs-list. If you lost your files, either look in the trashbin, or try to re-create them by building the layout again.
>
> If a layout remains after uninstallation (possible if a layout is repaired) then it can be removed via the Registry Editor. Run _regedit.exe_ and go to _HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Keyboard Layouts_ to view the complete list of keyboard layouts. At the bottom of the list, folders starting with 'a' are custom layouts which can be deleted altogether.
>
> There is one last resort if layout data is haunting your harddrive. I do not recommend you do it, because it involves modifying system-files, and it has a success rate of less than 50%, in my experience (that is 50% of successfully removing your layouts from the list, not 50% of you successfully not FUBAR-ing your system). But if you must, here is what you can try to do:  
> Go to these two directories: _C:\\Windows\\System32_ and _C:\\Windows\\SysWOW64_. In both directories, you should be able to find a file _YOURLAYOUT.dll_, with whatever name you specified in MSKLC. Look for the file in both directories (sorting alphabetically can help), and then delete the file from both. Don't delete any other files, because that can brick your system. Restart once you are done, and hope for the best.

## „WACUP“ *R* ir *S* klavišų problema
Naudojant „WACUP“ grotuvą su „Colemak-DH“ išsidėstymu, *R* ir *S* klavišai atsiduria vienas šalia kito – naudojant *shuffle* funkciją yra tikimybė netyčia išjungti grojaraščio išmaišymą sumaišius klavišus (*R* klavišas atsakingas už kartojimą, angl. *repeat*), dėl ko vėlesnis įjungimas permaišytų iš naujo nuo pačios pradžios. Taip pat paspaudus vidurinį pelės mygtuką ir sukant ratuką, dabartinė daina bus slenkama ratuko judėjimo kryptis. Man tai nėra priimtina veiksena, todėl `euromak_lt_ro.exe` puikiai veikia kaip foninis *AutoHotkey* procesas, kuris abiejų veiksenų klavišus sustabdo aptikus „WACUP“ langą.
Norint realizuoti šį sprendimą, reikia kompiliuoti `euromak_lt_ro wacup.ahk` failą *Ahk2Exe* programa, vietoje nurodyto `euromak_lt_ro.ahk.

 ## Naujausia versija
~~Naujausioje versijoje pridėtas kazachiškų rašmenų palaikymas ukrainietiškame „JCUKEN“ klaviatūros išsidėstyme. Norint naudoti naujausią versiją, reikia atlikti [[#MSKLC]] veiksmus papildomai sukonfigūruojant klaviatūros išsidėstymą, naudojant `ukr.klc` failą vietoje  `cm-dh_us.klc` (kartu, iš tiesų). Naujausios versijos *AutoHotkey* failas – `euromak_lt_ro wacup kz.ahk`.~~  Naujausia versija – `euromak_lt_ro wacup.ahk`. Kompiliuojant šį failą taip pat pasirinkti šį nustatymą: *Base File (.bin, .exe) – U64 Unicode 64-bit.bin*.
* Naujausia versija leidžia tiesiai naudoti *UTF-8* koduotės raides iš *stringų*, kaip nurodyta tekstiniame faile. Atliekant pakeitimus šiame faile, būtina jį išsaugoti *UTF-8 with BOM* formatu.
Pridėtas „WACUP“ lango aptikimas ir užrakinant ekraną lango aktyvavimas viršuje, kad būtų rodomas grojantis failas.
* Šis būdas dažnai veikia, bet ne visada.
# Linux
Nėra paprasto būdo visose „Linux“ distribucijose užtikrinti vienodą veikimą. Vienas iš būdų, `Failai\Euromak files\Linux\IBus edition` aplanke yra pateiktas *tar* archyvas su failais, kuriais galima bent iš dalies atkartoti dvikalbį *AutoHotkey* variantą.

## IBus dvikalbis būdas
Šis būdas veikia tik su „Ubuntu“ distribucija ir jos atmainomis – „Fedora“ distribucijoje griežtai neveikia, kitose distribucijose neišbandytas.
Tam reikia įdiegti paketus `ibus` ir `sxhkd` komanda:
```
sudo apt install ibus sxhkd
```
ir įtraukti *ibus* kaip pasirinktą įvesties būdą aplinkos kintamuosiuose:
```
export GTK_IM_MODULE=ibus QT_IM_MODULE=ibus XMODIFIERS=@im=ibus
```
atstatyti galima naudojant šią:
```
unset GTK_IM_MODULE QT_IM_MODULE XMODIFIERS

```
Dabar galima tiesiai išskleisti į *home/\[naudotojas\]* vietą atžymint *Ensure a containing directory* parinktį.
Failų struktūra:
* `.layout` – laikomi du *.Xcompose* tipo klaviatūros išsidėstymo pertvarkymo failai
	* `state` – nurodo dabartinį kalbos kodą, numatytieji čia `LT` ir `RO`.
	* `ROlayout` – rumuniškasis pertvarkymo failas
	* `LTlayout` – lietuviškasis pertvarkymo failas
* `.XCompose` – failas, kuris laiko dabartinį pertvarkymo failą.
* `.switch.sh` – failas, kuris sukeičia pertvarkymo failus atsižvelgiant į būseną (`state` failą).

* `.Xmodmap` – failas, kuris „išvalo“ *Caps Lock* klavišą nuo savo funkcionalumo ir „rakinimo“ galimybės ir prideda tariamo *F15* klavišo reikšmę. Taip pat pridėtas dolerio ženklas ($) spaudžiant *Shift* ir *Enter* klavišus kartu.
* `.config/sxhkd/sxhkdrc` – konfigūracijos failas *sxhkdrc* programai iššaukti `.switch.sh` skriptą spaudžiant *„F15“ Caps Lock* klavišą.
Užtikrinant veikimą, `xmodmap ~/.Xmodmap` ir `sxhkd` komandos turi būti paleistos pradedant grafinės aplinkos sesiją, kitaip sakant prisijungiant prie naudotojo paskyros. „Xubuntu“ automatiškai paleidžia `xmodmap ~/.Xmodmap`, todėl reikia tik `sxhkd` priskirti prie automatinio paleidimo.
### Žinomos problemos
„Ubuntu“ ir „Ubuntu Unity“ atmainose nepavyko pridėti abi komandas prie automatinio paleidimo – veikia tik `xmodmap ~/.Xmodmap` praėjus kuriam laikui nuo sesijos pradžios.
„Fedora“ distribucijoje naudojant net ir skirtingas grafines aplinkas (bandytos *LXDE* ir *XFCE*) pakeistas pertvarkymo failas ir perkrautas *IBus* įvesties būdas neįvykdys pakeitimų dabartiniame lange – spaudžiant `4` ir `t` klavišus jau atidarytame terminalo lange prieš pakeitimą duos `š` raidę, po pakeitimo naujai atidarytame lange bus `ș` raidė. Nėra aiškaus būdo tai išspręsti.

## Paprastas vienakalbis būdas
Naudojant vieną kalbą viskas yra ganėtinai paprasta – užtenka nueiti į `Failai\Euromak files\Linux\Regular` ir nuvilkti pasirinktos kalbos pertvarkymo failą į *home/\[naudotojas\]* vietą jį pervadinus `.XCompose`. Tada atsijungti nuo sesijos ir pradėti naują. Dabar pakeitimai bus pritaikyti ir bus galima naudoti `4` klavišą išgaunant raides.