//
//  ArticleDetailView.swift
//  PulseCor
//
//
// ArticleDetailView.swift
import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageName = article.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(16)
                } else {
                    Rectangle()
                        .fill(LinearGradient(colors: [Color("AccentCoral"), Color("AccentPink")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 250)
                        .cornerRadius(16)
                }
                
                Text(article.title)
                    .font(.appTitle)
                    .foregroundColor(Color("MainText"))
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Text(article.category.rawValue)
                        .font(.appBodySemibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color("AccentCoral")))
                    Spacer()
                }
                
                if !article.summary.isEmpty {
                    Text(article.summary)
                        .font(.appBodyLargeSemibold)
                        .foregroundColor(Color("MainText").opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 8)
                }
                
                Divider().padding(.vertical, 8)
                
                Text(article.content)
                    .font(.appLink)
                    .foregroundColor(Color("MainText"))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(Color("MainBG"))
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
    }
}
