# screens_lead — Practice 6: Screens That Lead to Screens

Лабораторная работа по курсу Mobile Development (КБТУ).

Приложение из трёх экранов: **список студентов → карточка студента → форма редактирования**, которая возвращает новое имя обратно. Потом навигация переводится со строк на именованные маршруты. В конце кнопка «назад» начинает спрашивать подтверждение, если в форме есть несохранённые изменения.

```
Students ──tap──▶ Detail (Aida) ──Edit──▶ Edit name
   ▲                 ▲    │                   │
   └──── back ───────┘    └◀── pop("Aida A.") ┘
```

Проверено на Flutter 3.47.3 (stable) и Dart 3.13.3: `flutter analyze` пишет `No issues found!`, `dart format .` ничего не меняет, `flutter test` проходит (5 тестов).

---

## Содержание

1. [Запуск](#запуск)
2. [Ментальная модель: Navigator — это стек](#ментальная-модель-navigator--это-стек)
3. [Структура проекта](#структура-проекта)
4. [Три правила проекта и как они соблюдены](#три-правила-проекта-и-как-они-соблюдены)
5. [Какие неоднозначности были и что я выбрал](#какие-неоднозначности-были-и-что-я-выбрал)
6. [Уровень 1 — Skeleton](#уровень-1--skeleton)
7. [Уровень 2 — List to detail](#уровень-2--list-to-detail)
8. [Уровень 3 — A screen that answers](#уровень-3--a-screen-that-answers)
9. [Уровень 4 — Names, not strings](#уровень-4--names-not-strings)
10. [Уровень 5 — The back button asks](#уровень-5--the-back-button-asks)
11. [Сломай специально](#сломай-специально)
12. [Автотесты](#автотесты)
13. [Финальный чек-лист](#финальный-чек-лист)
14. [Скриншоты](#скриншоты)
15. [Коммит в GitHub](#коммит-в-github)

---

## Запуск

```bash
cd screens_lead
flutter pub get
flutter run            # выбрать симулятор / эмулятор / устройство
flutter analyze        # → No issues found!
dart format .          # → 0 changed
flutter test           # → All tests passed!
```

---

## Ментальная модель: Navigator — это стек

`Navigator` хранит **стек маршрутов** (`Route`). На экране виден только верхний.

| Операция | Что делает со стеком | Что получает вызывающий |
|---|---|---|
| `push(route)` | кладёт новый экран сверху | `Future<T?>`, который завершится, когда этот экран снимут |
| `pop([result])` | снимает верхний экран | `result` попадает в тот самый `Future` |
| `canPop()` | `true`, если под текущим есть ещё экран | — |
| `maybePop()` | «вежливый» pop: сначала спрашивает `PopScope` | — |

Главное: **нижний экран не уничтожается**. Пока сверху открыт другой экран, нижний лежит в стеке живым. Его `State`, позиция скролла, введённый текст и контроллеры остаются нетронутыми. После `pop` он просто снова становится видимым, без пересоздания.

Из этого следует, что `push` работает как «вызов функции», а `pop(result)` — как её `return`:

```dart
final name = await Navigator.of(context).push<String>(...); // "call"
// ... в другом экране:
Navigator.of(context).pop('Aida A.');                        // "return"
```

---

## Структура проекта

```
screens_lead/
├── lib/
│   ├── main.dart             # MaterialApp + таблица маршрутов (35 строк)
│   ├── students.dart         # класс Student + константный список students
│   ├── students_screen.dart  # экран 1: список
│   ├── detail_screen.dart    # экран 2: карточка студента
│   ├── edit_screen.dart      # экран 3: форма, возвращает новое имя
│   └── routes.dart           # имена маршрутов (появляется на Уровне 4)
├── test/
│   └── widget_test.dart      # 5 widget-тестов на сценарии задания
├── screenshot_detail.png     # добавить вручную, см. раздел «Скриншоты»
├── screenshot_dialog.png     # добавить вручную
└── README.md
```

Граф зависимостей в финальной версии. Стрелка означает «импортирует»:

```
main.dart ──▶ routes.dart
    │──────▶ students_screen.dart ──▶ routes.dart, students.dart
    │──────▶ detail_screen.dart   ──▶ routes.dart, students.dart
    │──────▶ edit_screen.dart     ──▶ students.dart
    └──────▶ students.dart
```

Экраны **не знают друг о друге**. Они знают только имена маршрутов. Связывает всё `main.dart`.

---

## Три правила проекта и как они соблюдены

1. **Никакой ручной стрелки назад.** В коде нет ни `BackButton`, ни `leading:` в `AppBar`. `AppBar` сам проверяет `ModalRoute`/`Navigator.canPop()` и рисует стрелку, только если под экраном есть другой экран. Поэтому на корневом списке стрелки нет, а на Detail и Edit она есть. (`leading:` в коде встречается только у `ListTile`. Это иконка строки, к `AppBar` она отношения не имеет.)
2. **Данные только через конструктор.** `DetailScreen(student: …)`, `EditScreen(student: …)`. Глобального «текущего студента» нет. Даже на Уровне 4, где переход идёт по имени, `onGenerateRoute` достаёт аргумент и всё равно передаёт его **в конструктор**. Сами экраны не читают `ModalRoute.of(context).settings.arguments`.
3. **`main.dart` короче 40 строк.** На Уровнях 1–3 в нём 17 строк, на Уровнях 4–5 — 35.

---

## Какие неоднозначности были и что я выбрал

| Вопрос | Решение и почему |
|---|---|
| Где лежит `Student`? | В `students.dart` вместе с данными, как в стартовом коде. Отдельный `student.dart` для одного маленького класса не нужен. |
| Где писать `onGenerateRoute`: в `main.dart` или в `routes.dart`? | В `main.dart`, рядом с `routes:`. Тогда `routes.dart` остаётся чистым списком констант, как в задании, и не появляется циклический импорт `routes.dart ↔ detail_screen.dart`. Всё вместе — это и есть «таблица маршрутов», и `main.dart` занимает 35 строк. |
| `MaterialPageRoute` для `/edit` с типом или без? | **С типом: `MaterialPageRoute<String>`.** Внутри `pushNamed<String>` Flutter делает приведение `route as Route<String?>?`. Без `<String>` получится `MaterialPageRoute<dynamic>`, и при нажатии Edit приложение упадёт. Подробности в разделе «Сломай специально». |
| Поле «стартует пустым», но черновик `_name` = старое имя. Что увидит пользователь? | `hintText: widget.student.name`: в пустом поле серым показано текущее имя. Если нажать Save, ничего не вводя, вернётся старое имя. Это безопасно. |
| `mounted` или `context.mounted` в PopScope? | Как в задании, `context.mounted`. Поэтому логика диалога написана **прямо в колбэке внутри `build`**, где `context` — параметр `build`. Если вынести её в метод `State`, линтер `use_build_context_synchronously` потребует уже `mounted` (проверено: в методе State на `context.mounted` линтер ругается). |
| Отражается ли новое имя в списке? | Нет, и задание этого не требует: `students` — `const`, а `DetailScreen` правит **свою локальную копию** `_student`. Вернуть изменение в список можно тем же приёмом, что на Уровне 3: `await pushNamed<Student>` из списка. |

---

## Уровень 1 — Skeleton

### Что меняется

Создаётся проект `flutter create screens_lead`. В `lib/` лежат `main.dart` и `students.dart` из стартового кода и новый `students_screen.dart`.

> `main.dart` и `students.dart` — стартовый код без изменений, только отформатированный `dart format`. Начиная с Dart 3.7 форматтер использует «tall style», поэтому отступы внутри `MaterialApp(...)` стали 4 пробела вместо 8.

**lib/main.dart**

```dart
import 'package:flutter/material.dart';

import 'students_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    ),
    home: const StudentsScreen(),
  );
}
```

**lib/students.dart**

```dart
class Student {
  const Student({required this.name, required this.group, required this.email});
  final String name;
  final String group;
  final String email;

  Student copyWith({String? name}) =>
      Student(name: name ?? this.name, group: group, email: email);
}

const students = [
  Student(name: 'Aida Akhmetova', group: 'IT-2302', email: 'aida@kbtu.kz'),
  Student(name: 'Dias Nurlanov', group: 'IT-2302', email: 'dias@kbtu.kz'),
  Student(name: 'Madina Serik', group: 'IT-2303', email: 'madina@kbtu.kz'),
  Student(name: 'Alikhan Bekov', group: 'IT-2303', email: 'alikhan@kbtu.kz'),
  Student(name: 'Zhanel Tolegen', group: 'IT-2304', email: 'zhanel@kbtu.kz'),
  Student(name: 'Arman Kairat', group: 'IT-2304', email: 'arman@kbtu.kz'),
  Student(name: 'Kamila Dosym', group: 'IT-2305', email: 'kamila@kbtu.kz'),
  Student(name: 'Yerlan Sadyk', group: 'IT-2305', email: 'yerlan@kbtu.kz'),
];
```

**lib/students_screen.dart**

```dart
import 'package:flutter/material.dart';

import 'students.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Root of the stack: canPop() is false, so AppBar draws no arrow.
      appBar: AppBar(title: const Text('Students')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, i) {
          final s = students[i];
          return ListTile(
            leading: CircleAvatar(child: Text(s.name[0])),
            title: Text(s.name),
            subtitle: Text(s.group),
            trailing: const Icon(Icons.chevron_right),
          );
        },
      ),
    );
  }
}
```

### Ключевые места

- `ListView.builder` строит строки **лениво**: создаются только видимые строки (плюс небольшой запас). Для 8 студентов разницы не видно, для 8000 она огромная.
- `s.name[0]` — первая буква имени для `CircleAvatar`.
- Стрелки назад нет, хотя мы ничего для этого не делали. `StudentsScreen` — первый и единственный маршрут в стеке, `canPop()` возвращает `false`, и `AppBar` не добавляет `leading`.

### Как проверить руками

1. `flutter run` → виден заголовок «Students» и 8 строк с аватаром, именем, группой и `›`.
2. Стрелки назад в AppBar нет.
3. Тап по строке ничего не делает (`onTap` пока нет).

---

## Уровень 2 — List to detail

### Что меняется

| Файл | Изменение |
|---|---|
| `lib/detail_screen.dart` | **новый**: `StatelessWidget`, принимает `Student` |
| `lib/students_screen.dart` | у `ListTile` появился `onTap` с `push(MaterialPageRoute(...))` |
| `main.dart`, `students.dart` | без изменений |

**lib/students_screen.dart**

```dart
import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'students.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Root of the stack: canPop() is false, so AppBar draws no arrow.
      appBar: AppBar(title: const Text('Students')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, i) {
          final s = students[i];
          return ListTile(
            leading: CircleAvatar(child: Text(s.name[0])),
            title: Text(s.name),
            subtitle: Text(s.group),
            trailing: const Icon(Icons.chevron_right),
            // builder is a function: the screen is built lazily by the route.
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => DetailScreen(student: s))),
          );
        },
      ),
    );
  }
}
```

**lib/detail_screen.dart**

```dart
import 'package:flutter/material.dart';

import 'students.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No leading: AppBar sees canPop() == true and adds the arrow itself.
      appBar: AppBar(title: Text(student.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.school),
            title: Text(student.group),
            subtitle: const Text('Group'),
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: Text(student.email),
            subtitle: const Text('Email'),
          ),
        ],
      ),
    );
  }
}
```

### Ключевые места

**Почему `builder` — функция, а не готовый виджет?** `MaterialPageRoute` сам решает, **когда** и **сколько раз** строить страницу: при первом показе, при перестроении маршрута (например, при смене темы или `MediaQuery`) и во время анимации перехода. Кроме того, `builder` получает **новый `BuildContext`** — контекст внутри нового маршрута, ниже `Navigator` и его `Overlay`. Готовый виджет был бы создан заранее, в контексте списка, и маршрут не смог бы пересоздать его. Функция означает «рецепт» экрана, а не сам экран. Параметр `_` здесь и есть этот новый контекст (нам он не нужен, поэтому `_`).

**Стек при переходе:**

```
 старт             tap «Aida»              back
┌──────────┐      ┌──────────┐            ┌──────────┐
│          │      │  Aida    │ ◀── top    │          │
│ Students │ ───▶ ├──────────┤  ───pop──▶ │ Students │
│          │      │ Students │ (живой)    │          │
└──────────┘      └──────────┘            └──────────┘
 [Students]       [Students, Aida]         [Students]
```

**Почему список не перестраивается и помнит скролл.** Пока сверху открыт `DetailScreen`, маршрут списка остаётся в `Overlay` с `maintainState: true`. Его элементы, `State` и `ScrollPosition` живы, просто не видны. `pop` снимает только верхний маршрут, а нижний показывается таким, каким был: `build` не вызывается, `ScrollController` не сбрасывается.

**Стрелка назад на Detail появилась сама.** Мы её не писали: `AppBar` увидел, что под ним есть маршрут (`canPop() == true`). Она вызывает `Navigator.maybePop(context)`. То же самое делают системная кнопка «назад» на Android и свайп от края на iOS.

### Как проверить руками

1. Прокрутить список немного вниз (на маленьком экране или в landscape).
2. Тап по «Aida Akhmetova» → открывается экран с заголовком «Aida Akhmetova», строками «IT-2302» (иконка школы) и «aida@kbtu.kz» (иконка почты). В AppBar есть стрелка ←.
3. Нажать ← (или системный back / свайп) → вернулись в список **на ту же позицию скролла**, без мерцания и перестроения.
4. На корневом списке стрелки по-прежнему нет.

---

## Уровень 3 — A screen that answers

### Что меняется

| Файл | Изменение |
|---|---|
| `lib/edit_screen.dart` | **новый**: `StatefulWidget` с черновиком `_name`, `TextField` без контроллера и кнопкой Save → `pop(_name)` |
| `lib/detail_screen.dart` | стал `StatefulWidget` с `late Student _student`. В AppBar появилась кнопка Edit → `_edit()` |
| остальные | без изменений |

**lib/detail_screen.dart**

```dart
import 'package:flutter/material.dart';

import 'edit_screen.dart';
import 'students.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.student});

  final Student student;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Local copy: the screen can change it without touching the list.
  late Student _student = widget.student;

  Future<void> _edit() async {
    // push<String> makes the result String? instead of Object?.
    final name = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => EditScreen(student: _student)),
    );
    // null = user pressed back; !mounted = this screen is already gone.
    if (name == null || !mounted) return;
    setState(() => _student = _student.copyWith(name: name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _edit,
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.school),
            title: Text(_student.group),
            subtitle: const Text('Group'),
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: Text(_student.email),
            subtitle: const Text('Email'),
          ),
        ],
      ),
    );
  }
}
```

**lib/edit_screen.dart**

```dart
import 'package:flutter/material.dart';

import 'students.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.student});

  final Student student;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  // Draft value: starts as the current name, updated on every keystroke.
  late String _name = widget.student.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit name')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // No controller: the field starts empty, hint shows the old name.
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'New name',
                hintText: widget.student.name,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _name = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              // pop(value) closes the screen and completes the caller's await.
              onPressed: () => Navigator.of(context).pop(_name),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Ключевые места

**`late Student _student = widget.student;`**: `late` нужен потому, что `widget` в инициализаторе поля ещё недоступен. `late` откладывает вычисление до первого обращения, а к тому моменту `widget` уже есть. Это **локальная копия**: экран может её менять, не трогая исходные данные.

**Зачем generic `push<String>`.** Без него `push` возвращает `Future<Object?>`, и `name` получится типа `Object?`. Тогда `copyWith(name: name)` не скомпилируется, и придётся писать небезопасное `as String`. С `<String>` переменная `name` получает тип `String?`. Знак `?` честно говорит, что результата может не быть.

**Три строки после `await`:**

```dart
final name = await Navigator.of(context).push<String>(...);   // 1
if (name == null || !mounted) return;                          // 2
setState(() => _student = _student.copyWith(name: name));      // 3
```

1. **`await`**: `push` возвращает `Future`, который завершится **только когда EditScreen снимут со стека**. Пока он открыт, `_edit()` «заморожен» на этой строке. Значение `Future` — то, что передали в `pop(...)`.
2. **`name == null`**: пользователь ушёл через back, а не через Save. Back вызывает `pop()` без аргумента, поэтому результат `null`. Ничего менять не нужно.
   **`!mounted`**: пока мы ждали, `DetailScreen` мог исчезнуть из дерева (например, кто-то вызвал `popUntil`/`pushNamedAndRemoveUntil`, или пришёл deep link). Тогда `setState` на мёртвом `State` выбросит `setState() called after dispose()`. Кроме того, после `await` нельзя пользоваться `context`, не проверив `mounted`. Это правило линтера `use_build_context_synchronously`.
3. **`setState`**: меняем локальную копию через `copyWith` (сам `Student` неизменяемый) и просим Flutter перестроить экран, чтобы заголовок AppBar показал новое имя.

**Черновик в EditScreen.** `_name` — это черновик. `TextField` без контроллера на каждое нажатие клавиши вызывает `onChanged`, и мы кладём текст в `_name`. Контроллер не нужен: начальный текст мы не задаём (поле пустое по заданию), а читать значение можно прямо из `_name`.

**Стек на Уровне 3:**

```
[Students, Aida] ──Edit──▶ [Students, Aida, Edit] ──Save: pop("Aida A.")──▶ [Students, Aida]
                                                                              └─ await вернул "Aida A."
                                                    ──back: pop()───────────▶ [Students, Aida]
                                                                              └─ await вернул null
```

### Как проверить руками

1. Список → Aida → иконка ✏️ (Edit) → открыта форма «Edit name», поле пустое, серым подсказка «Aida Akhmetova».
2. Ввести «Aida A.» → Save → вернулись на Detail, заголовок стал **«Aida A.»**.
3. Ещё раз Edit → ввести что угодно → нажать ← (не Save) → заголовок **не изменился**, ошибок в консоли нет.
4. Edit → Save, ничего не вводя → имя осталось прежним (черновик изначально равен старому имени).

---

## Уровень 4 — Names, not strings

### Что меняется

| Файл | Изменение |
|---|---|
| `lib/routes.dart` | **новый**: три константы с именами маршрутов |
| `lib/main.dart` | `home:` заменён на `initialRoute` + `routes` + `onGenerateRoute` |
| `lib/students_screen.dart` | `push(MaterialPageRoute…)` заменён на `pushNamed(Routes.student, arguments: s)`. **Импорт `detail_screen.dart` удалён** |
| `lib/detail_screen.dart` | `push<String>(…)` заменён на `pushNamed<String>(Routes.edit, …)`. **Импорт `edit_screen.dart` удалён** |
| `edit_screen.dart`, `students.dart` | без изменений |

**lib/routes.dart**

```dart
abstract final class Routes {
  static const students = '/';
  static const student = '/student';
  static const edit = '/edit';
}
```

**lib/main.dart** (35 строк)

```dart
import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'edit_screen.dart';
import 'routes.dart';
import 'students.dart';
import 'students_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    ),
    initialRoute: Routes.students,
    routes: {Routes.students: (_) => const StudentsScreen()},
    // Routes that need an argument; unknown names fall through to null.
    onGenerateRoute: (settings) => switch (settings.name) {
      Routes.student => MaterialPageRoute(
        settings: settings,
        builder: (_) => DetailScreen(student: settings.arguments as Student),
      ),
      // <String> must match pushNamed<String>, otherwise the cast fails.
      Routes.edit => MaterialPageRoute<String>(
        settings: settings,
        builder: (_) => EditScreen(student: settings.arguments as Student),
      ),
      _ => null,
    },
  );
}
```

**lib/students_screen.dart**

```dart
import 'package:flutter/material.dart';

import 'routes.dart';
import 'students.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Root of the stack: canPop() is false, so AppBar draws no arrow.
      appBar: AppBar(title: const Text('Students')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, i) {
          final s = students[i];
          return ListTile(
            leading: CircleAvatar(child: Text(s.name[0])),
            title: Text(s.name),
            subtitle: Text(s.group),
            trailing: const Icon(Icons.chevron_right),
            // Only the route name is known here, not the DetailScreen class.
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.student, arguments: s),
          );
        },
      ),
    );
  }
}
```

**lib/detail_screen.dart**

```dart
import 'package:flutter/material.dart';

import 'routes.dart';
import 'students.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.student});

  final Student student;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Local copy: the screen can change it without touching the list.
  late Student _student = widget.student;

  Future<void> _edit() async {
    // pushNamed<String> makes the result String? instead of Object?.
    final name = await Navigator.of(context)
        .pushNamed<String>(Routes.edit, arguments: _student);
    // null = user pressed back; !mounted = this screen is already gone.
    if (name == null || !mounted) return;
    setState(() => _student = _student.copyWith(name: name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _edit,
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.school),
            title: Text(_student.group),
            subtitle: const Text('Group'),
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: Text(_student.email),
            subtitle: const Text('Email'),
          ),
        ],
      ),
    );
  }
}
```

### Ключевые места

**Почему `routes:` только для списка, а остальные экраны идут через `onGenerateRoute`.** Билдер в таблице `routes` получает только `BuildContext`, без аргументов. Экран без аргументов (`StudentsScreen`) туда подходит. Detail и Edit нужен `Student`. Его можно было бы достать внутри экрана через `ModalRoute.of(context)!.settings.arguments`, но это нарушает правило №2 (данные только через конструктор). `onGenerateRoute` получает `RouteSettings` с `name` и `arguments`, приводит аргумент к `Student` и **передаёт его в конструктор**. Экраны по-прежнему ничего не знают о маршрутизации.

**Порядок поиска маршрута** при `pushNamed(name)`: сначала таблица `routes`, потом `onGenerateRoute`, потом `onUnknownRoute`. Если `onGenerateRoute` вернул `null` и `onUnknownRoute` не задан, Flutter бросает ошибку «Could not find a generator for route».

**`home:` пришлось убрать.** `home` — это то же самое, что маршрут `'/'`. Если указать и `home`, и `routes['/']`, сработает assert (маршрут определён дважды).

**`MaterialPageRoute<String>` для `/edit` обязателен.** `pushNamed<String>` внутри делает `onGenerateRoute(settings) as Route<String?>?`. `MaterialPageRoute` без типа — это `MaterialPageRoute<dynamic>`, и такое приведение падает в рантайме. Тип маршрута должен совпадать с тем, что ждёт вызывающий.

**`settings: settings`** сохраняет имя и аргументы внутри маршрута. Без этого `ModalRoute.of(context)?.settings.name` будет `null`, и перестанут работать `popUntil(ModalRoute.withName(Routes.students))` и подписи в DevTools.

**Три строки после `await` в `_edit()` не изменились.** Именованный маршрут возвращает такой же `Future<String?>`.

**Почему это лучше строк.** Опечатка в `Routes.studnet` — **ошибка компиляции**. Опечатка в `'/studnet'` обнаружится только в рантайме, когда кто-то нажмёт на строку. Кроме того, все URL-подобные строки собраны в одном файле, и их легко переименовать.

### Как проверить руками

1. Поведение **точно такое же**, как на Уровне 3: список → Detail → Edit → Save меняет имя, back ничего не меняет.
2. Проверка импортов и строк:

   ```bash
   grep -n "detail_screen" lib/students_screen.dart   # → пусто
   grep -n "edit_screen"   lib/detail_screen.dart     # → пусто
   grep -rn "'/" lib | grep -v routes.dart            # → пусто
   wc -l lib/main.dart                                # → 35
   ```

---

## Уровень 5 — The back button asks

### Что меняется

| Файл | Изменение |
|---|---|
| `lib/edit_screen.dart` | геттер `_dirty`, `body` обёрнут в `PopScope` с диалогом «Discard changes?» |
| остальные | без изменений (финальные версии — в Уровне 4) |

**lib/edit_screen.dart**

```dart
import 'package:flutter/material.dart';

import 'students.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.student});

  final Student student;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  // Draft value: starts as the current name, updated on every keystroke.
  late String _name = widget.student.name;

  // Derived, not stored: can never get out of sync with _name.
  bool get _dirty => _name != widget.student.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit name')),
      body: PopScope(
        // Clean form: back works as usual. Dirty form: back is blocked.
        canPop: !_dirty,
        onPopInvokedWithResult: (didPop, _) async {
          // The pop already happened (clean form or Save) - nothing to do.
          if (didPop) return;
          final discard = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Discard changes?'),
              content: const Text('The new name has not been saved.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Keep editing'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          );
          // Tapping outside the dialog returns null, which counts as "keep".
          if (discard == true && context.mounted) Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // No controller: the field starts empty, hint shows the old name.
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'New name',
                  hintText: widget.student.name,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _name = v),
              ),
              const SizedBox(height: 16),
              FilledButton(
                // An explicit pop() from our own code is never blocked.
                onPressed: () => Navigator.of(context).pop(_name),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Ключевые места

**`_dirty` — геттер, а не поле.** «Форма изменена» — это **производное** состояние: оно полностью вычисляется из `_name` и исходного имени. Если хранить его в отдельном поле `bool _dirty`, его придётся вручную обновлять в каждом `setState`, и рано или поздно поле разойдётся с реальностью. Геттер вычисляется заново при каждом `build`, и рассинхронизация невозможна. Кстати, если стереть изменения и ввести ровно старое имя, форма снова становится «чистой».

**Как работает `PopScope`:**

- `canPop` — **синхронный** флаг, который Flutter знает **заранее**, до нажатия. При `canPop: true` back работает как обычно. При `canPop: false` back блокируется: стрелка в AppBar, системная кнопка Android и свайп на iOS не снимают экран.
- `onPopInvokedWithResult(didPop, result)` вызывается **при любой попытке** закрыть экран:
  - `didPop == true` — экран уже закрылся (форма была чистой, или сработал наш `pop(_name)` из Save). Делать ничего не нужно, поэтому первым идёт `if (didPop) return;`. Без этой проверки диалог выскочил бы после Save.
  - `didPop == false` — закрытие заблокировано, потому что форма грязная. Показываем `showDialog<bool>`. `Keep editing` возвращает `false`, `Discard` возвращает `true`, тап мимо диалога возвращает `null`.
- Если ответ `true` и `context` ещё смонтирован, делаем **настоящий** `Navigator.of(context).pop()`. Он не блокируется (см. ниже), и `_edit()` на Detail получает `null`, то есть «ничего не менять».

**Почему Save не спрашивает.** `PopScope` перехватывает только «просьбы» закрыть экран: `maybePop` (его вызывают стрелка AppBar и системный back) и predictive back. Прямой `Navigator.pop(...)` из нашего кода — это **команда**, а не просьба. Она выполняется всегда, а `PopScope` только получает уведомление с `didPop: true`.

**Почему `PopScope`, а не `WillPopScope`.** `WillPopScope` устарел. У него был асинхронный `onWillPop`, и Flutter не мог заранее знать, разрешён ли back. Начиная с Android 14 есть **predictive back**: система ещё во время жеста показывает анимацию «что будет под экраном», и ответ нужен синхронно и заранее. `PopScope.canPop` — как раз такой заранее известный ответ.

**`context.mounted`.** Пока открыт диалог, экран теоретически может исчезнуть. `context` здесь — параметр `build`, поэтому проверяем именно `context.mounted`. Подробнее — в таблице неоднозначностей выше.

### Как проверить руками (три случая)

| # | Действия | Ожидание |
|---|---|---|
| 1 | Edit → ничего не вводить → ← | Сразу вернулись на Detail, **диалога нет** (форма чистая) |
| 2 | Edit → ввести «Draft» → ← | Диалог **«Discard changes?»**. Keep editing → остались в форме, текст на месте. Снова ← → Discard → вернулись на Detail, имя **не изменилось** |
| 3 | Edit → ввести «Aida A.» → Save | **Диалога нет**, заголовок Detail стал «Aida A.» |

Плюс: на Android проверить системный back, на iOS свайп от левого края. В грязной форме свайп не должен срабатывать.

---

## Сломай специально

Всё ниже воспроизведено на этом проекте. Сообщения об ошибках скопированы из реального запуска (Flutter 3.47.3).

### Уровень 2: `leading: const BackButton()`

```dart
// students_screen.dart — DON'T
appBar: AppBar(leading: const BackButton(), title: const Text('Students')),
```

**Что будет.** Ошибки компиляции нет, и это хуже всего. На **корневом** экране появляется стрелка, которая **ничего не делает**: `BackButton` вызывает `maybePop`, а снимать со стека нечего (в тесте: стрелка 1 шт., после тапа мы всё ещё на списке). Пользователь видит сломанную кнопку.

**Почему так нельзя в принципе.** `AppBar` сам решает, нужна ли стрелка (`canPop`), и какая именно: для `fullscreenDialog: true` он рисует крестик ✕ вместо ←, а на iOS — платформенную иконку. Ручной `leading` отключает всю эту логику навсегда, даже когда экран станет корневым (deep link, `pushReplacement`). Отсюда правило №1.

### Уровень 3: `name!` вместо guard

```dart
// detail_screen.dart — DON'T
Future<void> _edit() async {
  final name = await Navigator.of(context).push<String>(...);
  setState(() => _student = _student.copyWith(name: name!));
}
```

**Что будет.** Save работает. Но стоит нажать ← на экране Edit, как `pop()` без аргумента вернёт `null`, и получим:

```
_TypeError: Null check operator used on a null value
```

**Почему.** Тип `String?` честно предупреждает, что результата может не быть, а `!` говорит компилятору «поверь мне, тут не null». Back — нормальный пользовательский сценарий, а не исключение. Кроме того, без `mounted` после `await` линтер выдаёт `use_build_context_synchronously`, а при уже уничтоженном экране будет `setState() called after dispose()`.

### Уровень 4: `pushNamed('/studnet')` против `Routes.studnet`

```dart
// Variant A — string typo
Navigator.of(context).pushNamed('/studnet', arguments: s);

// Variant B — constant typo
Navigator.of(context).pushNamed(Routes.studnet, arguments: s);
```

**Вариант A (строка).** `flutter analyze` и компиляция проходят: для Dart это просто строка. Ошибка появится **только при тапе по студенту**:

```
Could not find a generator for route RouteSettings("/studnet", Instance of 'Student')
in the _WidgetsAppState.
```

Причина: в `routes` такого ключа нет, `onGenerateRoute` попадает в ветку `_ => null`, а `onUnknownRoute` не задан.

**Вариант B (константа).** Код **даже не собирается**, и IDE подчёркивает опечатку сразу:

```
error • The getter 'studnet' isn't defined for the type 'Routes' • undefined_getter
```

В этом и смысл `routes.dart`: ошибка переезжает из рантайма (её найдёт пользователь) в компиляцию (её найдёт IDE).

### Бонус к Уровню 4: `MaterialPageRoute` без `<String>`

```dart
Routes.edit => MaterialPageRoute( // no <String>
```

Компиляция проходит, но при нажатии Edit:

```
type 'MaterialPageRoute<dynamic>' is not a subtype of type 'Route<String?>?' in type cast
```

`pushNamed<String>` ожидает маршрут, который «отвечает строкой». Тип маршрута и тип в `pushNamed<T>` должны совпадать.

---

## Автотесты

`test/widget_test.dart` покрывает сценарии из задания:

| Тест | Что проверяет |
|---|---|
| `root list has no back arrow` | на корневом экране нет `BackButton` |
| `tap opens detail with an automatic back arrow` | push → Detail с email и автоматической стрелкой → pop обратно |
| `Save returns the new name to detail` | `pop(_name)` → `await` → `setState` → новый заголовок, диалога нет |
| `clean form pops without a dialog` | чистая форма закрывается без вопроса |
| `dirty form asks before leaving` | грязная форма: диалог → Keep editing → Discard → имя не изменилось |

```bash
flutter test   # 00:01 +5: All tests passed!
```

> В тесте грязной формы после `enterText` стоит `await tester.pump()`. `enterText` вызывает `onChanged` → `setState`, но кадр сам не перерисовывается, поэтому без `pump()` `PopScope` ещё видел бы старое `canPop: true`. В реальном приложении кадр рисуется сам.

---

## Финальный чек-лист

- [x] `flutter analyze` → `No issues found!`
- [x] `dart format .` → `0 changed`
- [x] `main.dart` короче 40 строк → **35** (`wc -l lib/main.dart`)
- [x] нет `BackButton` и нет `leading:` в `AppBar` → `grep -rnE "BackButton|AppBar\(leading" lib` ничего не находит
- [x] нет строк, начинающихся с `'/`, вне `routes.dart` → `grep -rn "'/" lib | grep -v routes.dart` ничего не находит
- [x] `students_screen.dart` не импортирует `detail_screen.dart`, `detail_screen.dart` не импортирует `edit_screen.dart`
- [x] `PopScope` (не `WillPopScope`) работает в трёх случаях: грязная форма спрашивает, чистая нет, Save не спрашивает
- [x] `push<String>` / `pushNamed<String>`, guard `name == null || !mounted`
- [ ] `screenshot_detail.png` и `screenshot_dialog.png` в корне `screens_lead/`

---

## Скриншоты

Оба файла кладутся в корень `screens_lead/`.

**screenshot_detail.png** — экран деталей:

1. `flutter run` на симуляторе или эмуляторе.
2. Тап по «Aida Akhmetova» (можно сначала переименовать через Edit, чтобы было видно, что Уровень 3 работает).
3. Сделать снимок:
   - iOS Simulator: `⌘ + S` (сохранит на рабочий стол) или в терминале
     `xcrun simctl io booted screenshot screenshot_detail.png`
   - Android Emulator: кнопка 📷 на боковой панели или
     `adb exec-out screencap -p > screenshot_detail.png`
   - любое устройство, пока работает `flutter run`, из второго терминала:
     `flutter screenshot -o screenshot_detail.png`

**screenshot_dialog.png** — диалог подтверждения:

1. На Detail нажать ✏️ (Edit) → ввести любой текст (например, «Draft»).
2. Нажать ← в AppBar (или системный back) → появится «Discard changes?».
3. Снять экран так же, назвать `screenshot_dialog.png`.

---

## Коммит в GitHub

Из корня репозитория (`flutter_repo/`). Добавляйте **только папку `screens_lead`**: в рабочей копии могут быть посторонние незакоммиченные изменения из прошлых практик.

```bash
cd screens_lead
flutter analyze && dart format --set-exit-if-changed . && flutter test
cd ..

git status                       # убедиться, что ничего лишнего
git add screens_lead
git commit -m "Practice 6: screens that lead to screens"
git push origin main
```

Можно коммитить по уровням: после каждого уровня `git add screens_lead && git commit -m "practice 6: level N"`. Тогда история коммитов покажет, как проект рос.
