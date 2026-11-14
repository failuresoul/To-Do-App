//
//  ContentView.swift
//  TodoFirebaseApp
//
//  Created by Developer on 2026-11-14.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "checklist")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("TodoFirebaseApp")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
