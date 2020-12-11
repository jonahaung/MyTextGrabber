//
//  SavedItemsView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 1/12/20.
//

import SwiftUI

struct SavedItemsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(GridItem.Size.adaptive(minimum: 100, maximum: 180), spacing: 2, alignment: .center)]) {
                ForEach(items) { item in
                    VStack {
                        Text(item.text ?? "")
                            .lineLimit(20)
                           
                            .font(.system(size: 7))
                            .lineSpacing(0)
                            .padding(8)
                    }
                    .background(Rectangle().fill(Color.white).shadow(color: Color.black.opacity(0.2), radius: 2, x: 2, y: 2))
                    .frame(width: 120)
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

}

struct SavedItemsView_Previews: PreviewProvider {
    static var previews: some View {
        SavedItemsView()
    }
}
