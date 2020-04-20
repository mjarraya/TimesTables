//
//  ContentView.swift
//  TimesTables
//
//  Created by Montasar on 20/04/2020.
//  Copyright © 2020 Montasar. All rights reserved.
//

import SwiftUI

enum ButtonTypes {
    case primary
    case secondary
}

struct NumberButton: ViewModifier {
    var type: ButtonTypes
    
    func body(content: Content) -> some View {
        content
        .frame(width: 50, height: 50)
            .background(type == ButtonTypes.primary ? Color.purple : Color.white)
            .foregroundColor(type == ButtonTypes.primary ? Color.white : Color.purple)
        .cornerRadius(10)
    }
}



extension View {
    func numberButton(_ type: ButtonTypes) -> some View {
        self.modifier(NumberButton(type: type))
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                                              y: 0))
    }
}


struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content
    
    var body: some View {
        VStack {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }
    
    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
}

struct Game: View {
    @Binding var showMenu: Bool
    @Binding var selectedLevel: String
    @Binding var selectedTables: [Int]

    @State private var questions = [[Int]]()
    @State private var userAnswer = [String]()
    @State private var attempts = 0
    @State private var opacity = 1.0
    var current: [Int] {
        return questions.first ?? []
    }
    
    var body: some View {
        VStack {
            if current.count > 0 {
                HStack {
                    Text("\(current.first!)")
                        .numberButton(ButtonTypes.primary)
                    Text("x")
                        .numberButton(ButtonTypes.secondary)
                    Text("\(current.last!)")
                    .numberButton(ButtonTypes.primary)
                }.opacity(opacity)
                HStack {
                    ForEach(0...9, id: \.self) { number in
                        Button(action: {
                            self.addNumber(number: number)
                        }) {
                            Text("\(number)")
                                .numberButton(ButtonTypes.primary)
                        }
                    }

                }
                HStack {
                    ForEach(userAnswer, id: \.self) { number in
                        Text("\(number)")
                            .numberButton(ButtonTypes.primary)
                            .modifier(Shake(animatableData: CGFloat(self.attempts))).opacity(self.opacity)
                    }
                    if userAnswer.count > 0 {
                        Button(action: validateAnswer) {
                            Text("Validate")
                        }.opacity(opacity)

                        Button(action: resetAnswer) {
                            Text("Reset")
                        }.opacity(opacity)
                    }
                }
            } else {
                Button(action: restartGame) {
                    Text("Play again")
                }.opacity(opacity)
            }
        }.onAppear(perform: initGame)
    }
    func initGame() {
        for number in selectedTables {
            for i in 1...12 {
                questions.append([number, i])
            }
        }
        questions.shuffle()
        if let numberLevel = Int(selectedLevel) {
            questions = Array(questions.prefix(numberLevel))
        }
        
        self.opacity = 1
    }
    func addNumber(number: Int) {
        userAnswer.append(String(number))
    }
    func validateAnswer() {
        let answer = Int(userAnswer.joined())
        self.opacity = 0
        if answer == current.first! * current.last! {
            withAnimation(.easeOut(duration: 0.5)) {
                questions.removeFirst()
                userAnswer = []
                self.opacity = 1
            }
        } else {
            self.opacity = 1
            withAnimation {
                attempts += 1
            }
        }
    }
    func resetAnswer() {
        userAnswer = []
    }
    func restartGame() {
        withAnimation(.easeOut(duration: 0.5)) {
            showMenu = true
        }
    }
}

struct Menu: View {
    @State private var availableTables: [Int] = Array(1...12)
    @State private var availableLevels = ["5", "10", "20", "All"]

    @Binding var showMenu: Bool
    @Binding var selectedLevel: String
    @Binding var selectedTables: [Int]
    
    @State private var attempts = 0
    
    var body: some View {
        VStack {
            Text("Select tables:").font(.title).foregroundColor(.white).padding()
            GridStack(rows: 4, columns: 3) { row, col in
                Button(action: {
                    self.selectTable(table: row * 3 + col + 1)
                }) {
                    Text("\(row * 3 + col + 1)")
                }
                .frame(width: 50, height: 50)
                .background(self.selectedTables.contains(row * 3 + col + 1) ? Color.white : Color.purple)
                .cornerRadius(10)
                .foregroundColor(self.selectedTables.contains(row * 3 + col + 1) ? Color.purple : Color.white)
                .padding(10)
            }            .modifier(Shake(animatableData: CGFloat(attempts)))
            Text("How many questions ?").font(.title).foregroundColor(.white).padding()
            HStack {
                ForEach(availableLevels, id: \.self) { level in
                    Button(action: {
                        self.selectLevel(level: level)
                    }) {
                        Text(level)
                    }
                    .frame(width: 50, height: 50)
                    .background(level == self.selectedLevel ? Color.white : Color.purple)
                    .foregroundColor(level == self.selectedLevel ? Color.purple : Color.white)
                    .cornerRadius(10)
                }
            }
            Button(action: startGame) {
                Text("Play")
                    .frame(width: 100, height: 75)
                    .background(Color.purple)
                    .cornerRadius(20)
                    .foregroundColor(.white)
            }
            .padding(.top, 75)
            .modifier(Shake(animatableData: CGFloat(attempts)))
        }.padding(.bottom, 100)
    }
    func selectTable(table: Int) {
        if let index = selectedTables.firstIndex(of: table) {
            selectedTables.remove(at: index)
        } else {
            selectedTables.append(table)
        }
    }
    func selectLevel(level: String) {
        withAnimation {
            selectedLevel = level
        }
    }
    func startGame() {
        if selectedTables.isEmpty {
            withAnimation {
                attempts += 1
            }
        } else {
            showMenu = false
        }
    }
}

struct ContentView: View {
    @State private var showMenu = true
    @State private var selectedLevel = "All"
    @State private var selectedTables = [Int]()
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .topLeading, endPoint: .topTrailing).zIndex(0)
                                    .edgesIgnoringSafeArea(.all)
                if showMenu {
                    Menu(showMenu: $showMenu.animation(.easeIn(duration: 0.5)), selectedLevel: $selectedLevel, selectedTables: $selectedTables).zIndex(1)
                }
                else {
                    Game(showMenu: $showMenu, selectedLevel: $selectedLevel, selectedTables: $selectedTables).zIndex(1)
                }
            }
            .navigationBarItems(leading: showMenu ? nil : Button(action: {
                withAnimation(.easeOut(duration: 0.5)){
                    self.showMenu = true
                }
            }) {
                Text("🔁")
                })
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
