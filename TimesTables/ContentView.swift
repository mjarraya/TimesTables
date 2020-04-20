//
//  ContentView.swift
//  TimesTables
//
//  Created by Montasar on 20/04/2020.
//  Copyright © 2020 Montasar. All rights reserved.
//

import SwiftUI

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
    var body: some View {
        Text("GAME")
    }
}

struct Menu: View {
    @State private var availableTables: [Int] = Array(1...12)
    @State private var selectedTables = [Int]()
    @State private var availableLevels = ["5", "10", "20", "All"]
    @State private var selectedLevel = "All"
    @Binding var showMenu: Bool
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
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .topLeading, endPoint: .topTrailing).zIndex(0)
                                    .edgesIgnoringSafeArea(.all)
                if showMenu {
                    Menu(showMenu: $showMenu.animation(.easeIn(duration: 0.5))).zIndex(1)
                }
                else {
                    Game().zIndex(1)
                }
            }
            .navigationBarItems(leading: showMenu ? nil : Button(action: {
                withAnimation(.easeOut(duration: 0.5)){
                    self.showMenu = true
                }
            }) {
                Text("🔁").frame(width: 50, height: 37.5)
                })
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
