#include <array>
#include <iostream>

#include <QApplication>
#include <QCloseEvent>
#include <QKeyEvent>
#include <QResizeEvent>
#include <QWidget>

#include "Example.h"

//////////////////////////////////////////////////////////////////////
/// This class is used to test that the memory leak checks work as expected even when using a GUI
class SomeClass {
public:
    explicit SomeClass(int) {}
};

SomeClass *getC() {
    return new SomeClass{2};
}
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
/// Fereastra exemplului.
///
/// Stă în .cpp, nu în include/: interfața publică a bibliotecii rămâne Example.h, iar
/// UI-ul este doar wiring în app/ — astfel tests/ licheiază biblioteca și rulează fără Qt.
///
/// Suprasciem handlerii virtuali moșteniți din QWidget, deci nu declarăm Q_OBJECT și moc
/// nu are nimic de generat. Cum adăugați un semnal/slot propriu, adăugați Q_OBJECT în
/// clasă; CMAKE_AUTOMOC este deja activat în CMakeLists.txt și se ocupă de restul.
class Fereastra : public QWidget {
public:
    explicit Fereastra(QWidget *parent = nullptr) : QWidget(parent) {
        ///////////////////////////////////////////////////////////////////////////
        /// NOTE: sync with env variable APP_WINDOW from .github/workflows/cmake.yml
        /// xdotool caută fereastra după titlu în scripts/run_ui_test.sh
        setWindowTitle(QStringLiteral("My Window"));
        ///////////////////////////////////////////////////////////////////////////
        resize(800, 700);
        /// Un QWidget simplu nu primește evenimente de la tastatură decât dacă cere focus.
        setFocusPolicy(Qt::StrongFocus);
    }

protected:
    void resizeEvent(QResizeEvent *event) override {
        QWidget::resizeEvent(event);
        std::cout << "New width: " << event->size().width() << '\n'
                  << "New height: " << event->size().height() << '\n';
    }

    void keyPressEvent(QKeyEvent *event) override {
        std::cout << "Received key " << (event->key() == Qt::Key_X ? "X" : "(other)") << "\n";
        if (event->key() == Qt::Key_Escape) {
            close();  // close() cere închiderea; QCloseEvent de mai jos confirmă că s-a întâmplat
            return;
        }
        QWidget::keyPressEvent(event);
    }

    void closeEvent(QCloseEvent *event) override {
        std::cout << "Fereastra a fost închisă\n";
        QWidget::closeEvent(event);
    }
};

int main(int argc, char *argv[]) {
    std::cout << "Hello, world!\n";
    Example e1;
    e1.add(3);
    e1.g();
    std::array<int, 100> v{};
    int nr;
    std::cout << "Introduceți nr: ";
    /////////////////////////////////////////////////////////////////////////
    /// Observație: dacă aveți nevoie să citiți date de intrare de la tastatură,
    /// dați exemple de date de intrare folosind fișierul tastatura.txt
    /// Trebuie să aveți în fișierul tastatura.txt suficiente date de intrare
    /// (în formatul impus de voi) astfel încât execuția programului să se încheie.
    /// De asemenea, trebuie să adăugați în acest fișier date de intrare
    /// pentru cât mai multe ramuri de execuție.
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
    std::cin >> nr;
    /////////////////////////////////////////////////////////////////////////
    for(int i = 0; i < nr; ++i) {
        std::cout << "v[" << i << "] = ";
        std::cin >> v[i];
    }
    std::cout << "\n\n";
    std::cout << "Am citit de la tastatură " << nr << " elemente:\n";
    for(int i = 0; i < nr; ++i) {
        std::cout << "- " << v[i] << "\n";
    }
    ///////////////////////////////////////////////////////////////////////////
    /// Pentru date citite din fișier, NU folosiți tastatura.txt. Creați-vă voi
    /// alt fișier propriu cu ce alt nume doriți.
    /// Exemplu:
    /// std::ifstream fis("date.txt");
    /// for(int i = 0; i < nr2; ++i)
    ///     fis >> v2[i];
    ///
    ///////////////////////////////////////////////////////////////////////////

    SomeClass *c = getC();
    std::cout << c << "\n";
    delete c;  // comentarea acestui rând ar trebui să ducă la semnalarea unui mem leak

    ///////////////////////////////////////////////////////////////////////////
    /// QApplication = legătura cu platforma grafică + bucla de evenimente.
    /// Exact unul per proces, creat înainte de orice QWidget.
    QApplication app(argc, argv);

    Fereastra window;
    window.show();
    std::cout << "Fereastra a fost creată\n";
    ///////////////////////////////////////////////////////////////////////////
    /// NOTE: obligatoriu să limitați rata de redraw, ca să nu ardeți CPU/GPU ///
    /// Qt nu are bucla „clear → display” din SFML: redeseăm doar când ceva    ///
    /// s-a schimbat, cerând singuri un redraw prin update(). Dacă animați,    ///
    /// QTimer este echivalentul setFramerateLimit (nu un sleep într-o buclă): ///
    /// QTimer fps;                                                           ///
    /// QObject::connect(&fps, &QTimer::timeout, &window,                      ///
    ///                  [&window] { window.update(); });                     ///
    /// fps.start(33);                        // ~30 FPS                      ///
    ///////////////////////////////////////////////////////////////////////////

    /// exec() rulează bucla de evenimente și se întoarce când fereastra se închide
    /// (implicit, aplicația se termină atunci când ultima fereastră vizibilă a fost închisă).
    /// E funcție statică; `app` de mai sus contează doar pentru durată de viață.
    QApplication::exec();

    std::cout << "Programul a terminat execuția\n";
    return 0;
}
