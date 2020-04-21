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
            .frame(width: 60, height: 60)
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
    
    var current: [Int] {
        return questions.first ?? []
    }
    
    var body: some View {
        VStack {
            if current.count != 0 {
                VStack{
                    HStack {
                        Text("\(current.first!)")
                            .animation(.spring(response: 0.0, dampingFraction:0.2))
                            .numberButton(ButtonTypes.primary)
                        Text("x")
                            .animation(.spring(response: 0.0, dampingFraction:0.2))
                            .numberButton(ButtonTypes.secondary)
                        Text("\(current.last!)")
                            .animation(.spring(response: 0.0, dampingFraction:0.2))
                            .numberButton(ButtonTypes.primary)
                        
                    }
                    Spacer()
                    VStack {
                        HStack {
                            ForEach(userAnswer, id: \.self) { number in
                                Text("\(number)")
                                    .numberButton(ButtonTypes.primary)
                                    .modifier(Shake(animatableData: CGFloat(self.attempts)))
                            }
                        }
                        HStack {
                            Spacer()
                            if userAnswer.count > 0 {
                                Button(action: validateAnswer) {
                                    Text("OK")
                                    .frame(width: 75, height: 42.5)
                                    .background(Color.white)
                                    .foregroundColor(Color.purple)
                                    .cornerRadius(10)
                                }

                                Button(action: resetAnswer) {
                                    Text("Reset")
                                    .frame(width: 75, height: 42.5)
                                    .background(Color.white)
                                    .foregroundColor(Color.purple)
                                    .cornerRadius(10)
                                }

                                .modifier(Shake(animatableData: CGFloat(attempts)))
                            }
                            Spacer()
                        }
                        .padding(.top, 20)
                    }
                    Spacer()
                    VStack {
                        HStack {
                            ForEach(0...4, id: \.self) { number in
                                Button(action: {
                                    self.addNumber(number: number)
                                }) {
                                    Text("\(number)")
                                    .numberButton(ButtonTypes.primary)
                                }
                                
                            }
                        }
                        .padding(.top, 10)
                        HStack {
                            ForEach(5...9, id: \.self) { number in
                                Button(action: {
                                    self.addNumber(number: number)
                                }) {
                                    Text("\(number)")
                                 .numberButton(ButtonTypes.primary)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.bottom, 100)
            } else {
                VStack {
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: restartGame) {
                            Text("Play")
                                .font(.title)
                                .frame(width: 100, height: 75)
                                .background(Color.purple)
                                .cornerRadius(20)
                                .foregroundColor(Color.white)
                        }
                        .transition(.opacity)
                        Spacer()
                    }
                    Spacer()
                }
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
    }
    func addNumber(number: Int) {
        if userAnswer.count > 2 {
            withAnimation {
                attempts += 1
            }
        } else {
            withAnimation(.easeOut(duration: 0.2)){
                userAnswer.append(String(number))
            }
        }
    }
    func validateAnswer() {
        let answer = Int(userAnswer.joined())
        if answer == current.first! * current.last! {
            withAnimation {
                userAnswer = []
            }
            questions.removeFirst()

        } else {
            withAnimation {
                attempts += 1
            }
        }
    }
    func resetAnswer() {
        withAnimation {
            userAnswer = []
        }
    }
    func restartGame() {
        withAnimation(.easeOut(duration: 0.2)) {
            showMenu = true
        }
    }
}

struct Menu: View {
    @State private var availableTables: [Int] = Array(1...12)
    @State private var availableLevels = ["5", "10", "20", "All"] // change
    
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
                    .numberButton(self.selectedTables.contains(row * 3 + col + 1) ? ButtonTypes.secondary : ButtonTypes.primary)
                }
                .padding(10)
            }            .modifier(Shake(animatableData: CGFloat(attempts)))
            Text("How many questions ?").font(.title).foregroundColor(.white).padding()
            HStack {
                ForEach(availableLevels, id: \.self) { level in
                    Button(action: {
                        self.selectLevel(level: level)
                    }) {
                        Text(level)
                        .numberButton(level == self.selectedLevel ? ButtonTypes.secondary : ButtonTypes.primary)
                    }
                    
                }
            }
            Button(action: startGame) {
                Text("Play")
                    .font(.title)
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
                    Menu(showMenu: $showMenu.animation(.easeOut(duration: 0.2)), selectedLevel: $selectedLevel, selectedTables: $selectedTables).zIndex(1)
                }
                else {
                    Game(showMenu: $showMenu, selectedLevel: $selectedLevel, selectedTables: $selectedTables).zIndex(1)
                }
                
            }
                
            .navigationBarItems(leading: showMenu ? nil : Button(action: {
                withAnimation(.easeOut(duration: 0.2)){
                    self.showMenu = true
                }
            }) {
                Text("Settings")
            }
            .frame(width: 75, height: 37.5)
            .background(Color.purple)
            .foregroundColor(Color.white)
            .cornerRadius(10)
            )
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
