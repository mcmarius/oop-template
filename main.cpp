#include <ftxui/component/component.hpp>       // for Slider, Renderer, Vertical
#include <ftxui/component/component_base.hpp>  // for ComponentBase
#include <ftxui/component/screen_interactive.hpp>  // for ScreenInteractive
#include <ftxui/dom/elements.hpp>  // for separator, operator|, Element, size, text, vbox, xflex, bgcolor, hbox, GREATER_THAN, WIDTH, border, HEIGHT, LESS_THAN
#include <ftxui/screen/color.hpp>  // for Color

#include <Helper.h>

ftxui::Element ColorTile(int red, int green, int blue) {
    return ftxui::text("") | ftxui::size(ftxui::WIDTH, ftxui::GREATER_THAN, 14) |
           ftxui::size(ftxui::HEIGHT, ftxui::GREATER_THAN, 7) | ftxui::bgcolor(ftxui::Color::RGB(red, green, blue));
}

ftxui::Element ColorString(int red, int green, int blue) {
    return ftxui::text("RGB = (" +             //
                std::to_string(red) + "," +    //
                std::to_string(green) + "," +  //
                std::to_string(blue) + ")"     //
    );
}

int main() {
    /////////////////////////////////////////////////////////////////////////
    /// Observație: dacă aveți nevoie să citiți date de intrare de la tastatură,
    /// dați exemple de date de intrare folosind fișierul tastatura.txt
    /// Trebuie să aveți în fișierul tastatura.txt suficiente date de intrare
    /// (în formatul impus de voi) astfel încât execuția programului să se încheie.
    /// De asemenea, trebuie să adăugați în acest fișier date de intrare
    /// pentru cât mai multe ramuri de execuție.
    /// Dorim să facem acest lucru pentru a automatiza testarea codului, fără să
    /// mai pierdem timp de fiecare dată să introducem de la zero aceleași date de intrare.
    ///
    /// Pe GitHub Actions (bife), fișierul tastatura.txt este folosit
    /// pentru a simula date introduse de la tastatură.
    /// Bifele verifică dacă programul are erori de compilare, erori de memorie și memory leaks.
    ///
    /// Dacă nu puneți în tastatura.txt suficiente date de intrare, îmi rezerv dreptul să vă
    /// testez codul cu ce date de intrare am chef și să nu pun notă dacă găsesc vreun bug.
    /// Impun această cerință ca să învățați să faceți un demo și să arătați părțile din
    /// program care merg (și să le evitați pe cele care nu merg).
    ///
    /////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    /// Pentru date citite din fișier, NU folosiți tastatura.txt. Creați-vă voi
    /// alt fișier propriu cu ce alt nume doriți.
    /// Exemplu:
    /// std::ifstream fis("date.txt");
    /// for(int i = 0; i < nr2; ++i)
    ///     fis >> v2[i];
    ///
    ///////////////////////////////////////////////////////////////////////////
    ///                Exemplu de utilizare cod generat                     ///
    ///////////////////////////////////////////////////////////////////////////
    Helper helper;
    helper.help();
    ///////////////////////////////////////////////////////////////////////////
    ///
    ftxui::ScreenInteractive screen = ftxui::ScreenInteractive::TerminalOutput();

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///                                    Exemplu culori RGB                                           ///
    ///                                                                                                 ///
    ///    Sursa: https://github.com/ArthurSonzogni/FTXUI/blob/main/examples/component/slider_rgb.cpp   ///
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    int red = 128;
    int green = 25;
    int blue = 100;
    ftxui::Component slider_red = ftxui::Slider("Red  :", &red, 0, 255, 1);
    ftxui::Component slider_green = ftxui::Slider("Green:", &green, 0, 255, 1);
    ftxui::Component slider_blue = ftxui::Slider("Blue :", &blue, 0, 255, 1);

    ftxui::Component container = ftxui::Container::Vertical({
        slider_red,
        slider_green,
        slider_blue,
    });

    ftxui::Component renderer = ftxui::Renderer(container, [&] {
        return ftxui::hbox({
                   ColorTile(red, green, blue),
                   ftxui::separator(),
                   ftxui::vbox({
                       slider_red->Render(),
                       ftxui::separator(),
                       slider_green->Render(),
                       ftxui::separator(),
                       slider_blue->Render(),
                       ftxui::separator(),
                       ColorString(red, green, blue),
                   }) | ftxui::xflex,
               }) |
               ftxui::border | ftxui::size(ftxui::WIDTH, ftxui::LESS_THAN, 80);
    });
    ///////////////////////////////////////////////////////////////////////////////



    //////////////////////////////////////////////////////////////////////
    ///           Programul se va opri automat dupa 5 secunde           //
    std::thread auto_close([&] {                                //
        std::this_thread::sleep_for(std::chrono::seconds(5));  //
        screen.Exit();                                                  //
    });                                                                 //
    //////////////////////////////////////////////////////////////////////

    screen.Loop(renderer);

    auto_close.join();

    return 0;
}
