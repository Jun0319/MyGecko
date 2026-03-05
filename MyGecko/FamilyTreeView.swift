import SwiftUI

struct FamilyTreeView: View {
    let gecko: Gecko
    @Environment(\.dismiss) var dismiss
    
    // 🌟 [마법의 보관함] 꾹 누르고 있는 사진 데이터를 임시로 담아둘 공간입니다!
    @State private var zoomedImageData: Data? = nil
    
    // 🎨 프리미엄 컬러 세팅 (Éclat Privé 지정 hex값)
    let motherColor = Color(red: 255/255, green: 107/255, blue: 107/255) // #FF6B6B
    let fatherColor = Color(red: 107/255, green: 157/255, blue: 255/255) // #6B9DFF
    let offspringColor = Color(red: 46/255, green: 204/255, blue: 113/255) // #2ECC71
    let connectorLineColor = Color.secondary.opacity(0.3) // #CCCCCC (테두리와 동일 컬러)
    
    var body: some View {
        ZStack {
            // 🌊 에클라 프리베만의 프리미엄 솜사탕 오라(Aura) 배경
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                RadialGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.92, blue: 0.94).opacity(0.9), .clear]), center: .topLeading, startRadius: 50, endRadius: 600).edgesIgnoringSafeArea(.all)
                RadialGradient(gradient: Gradient(colors: [Color(red: 0.92, green: 0.95, blue: 1.0).opacity(0.9), .clear]), center: .topTrailing, startRadius: 50, endRadius: 600).edgesIgnoringSafeArea(.all)
                RadialGradient(gradient: Gradient(colors: [Color(red: 0.92, green: 0.98, blue: 0.96).opacity(0.9), .clear]), center: .bottom, startRadius: 50, endRadius: 500).edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: 0) {
                // 🧹 1. 세련된 통합형 닫기 버튼
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 40)
                }
                
                Spacer() // 2. 상단 여백
                
                // 🧬 3. 혈통서(Family Tree) 전체 계층 영역
                ZStack {
                    VStack(spacing: 0) {
                        // A. 부모(Parents) 가로 레이아웃
                        HStack(spacing: 0) {
                            // ❤️ 엄마(Dam) 블록
                            FamilyMemberBlock(title: "MOTHER", titleColor: motherColor, geckoName: gecko.damName.isEmpty ? "정보 없음" : gecko.damName, geckoId: gecko.damMorph.isEmpty ? "정보 없음" : gecko.damMorph, imageData: gecko.damImageData, placeholderEmoji: "🌿")
                            
                            // 🌟 부모 연결선 & 하트 오버레이
                            ZStack {
                                Path { path in
                                    path.move(to: CGPoint(x: -30, y: 130))
                                    path.addCurve(to: CGPoint(x: 110, y: 130), control1: CGPoint(x: -25, y: 190), control2: CGPoint(x: 105, y: 190))
                                }
                                .stroke(connectorLineColor, lineWidth: 2.5)
                                
                                ZStack {
                                    Circle().fill(Color.white.opacity(0.8)).frame(width: 30, height: 30)
                                    Image(systemName: "heart.fill").font(.system(size: 18)).foregroundColor(motherColor.opacity(0.6))
                                }
                                .offset(y: 50)
                            }
                            .frame(width: 80)
                            
                            // 💙 아빠(Sire) 블록
                            FamilyMemberBlock(title: "FATHER", titleColor: fatherColor, geckoName: gecko.sireName.isEmpty ? "정보 없음" : gecko.sireName, geckoId: gecko.sireMorph.isEmpty ? "정보 없음" : gecko.sireMorph, imageData: gecko.sireImageData, placeholderEmoji: "🌺")
                        }
                        
                        // B. 중앙 점선 라인
                        AnimatedDotLine(color: Color(hex: "08f137"), height: 85, dotSize: 4, gap: 8, stepDuration: 0.18)
                            .padding(.vertical, 15)
                        
                        // C. 자손(Offspring) 블록
                        FamilyMemberBlock(title: "OFFSPRING", titleColor: offspringColor, geckoName: gecko.name, geckoId: gecko.morph.isEmpty ? "정보 없음" : gecko.morph, imageData: gecko.profileImageData, placeholderEmoji: "🦎")
                    }
                    .padding(.horizontal)
                }
                
                Spacer() // 4. 하단 여백
            }
            
            // 🌟 [핵심 추가] 꾹 누르고 있을 때 화면 중앙에 뜨는 확대 오버레이!
            if let data = zoomedImageData, let uiImage = UIImage(data: data) {
                ZStack {
                    // 뒷배경을 살짝 어둡게 (블러 효과)
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    // 원형을 유지한 채로 2.5배 확대된 큼직한 사진!
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 250, height: 250) // 사진 크기 조절 가능
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                }
                .zIndex(100) // 화면의 가장 맨 위에 뜨도록 강제!
                .transition(.scale(scale: 0.8).combined(with: .opacity)) // 스르륵 나타나는 애니메이션 효과
            }
        }
        // 🌟 확대/축소될 때 쫀득한 젤리 같은 애니메이션 세팅
        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: zoomedImageData)
    }

    private struct AnimatedDotLine: View {
        let color: Color
        let height: CGFloat
        let dotSize: CGFloat
        let gap: CGFloat
        let stepDuration: Double
        @State private var startDate = Date()
        private var dotCount: Int {
            let total = (height + gap) / (dotSize + gap)
            return max(1, Int(total.rounded(.down)))
        }
        var body: some View {
            TimelineView(.animation) { context in
                let elapsed = context.date.timeIntervalSince(startDate)
                let phase = (elapsed / stepDuration).truncatingRemainder(dividingBy: Double(dotCount))
                VStack(spacing: gap) {
                    ForEach(0..<dotCount, id: \.self) { index in
                        Circle().fill(color).frame(width: dotSize, height: dotSize).opacity(opacity(for: index, phase: phase))
                    }
                }
                .frame(width: dotSize, height: height, alignment: .top)
            }
        }
        private func opacity(for index: Int, phase: Double) -> Double {
            guard dotCount > 0 else { return 0.2 }
            let position = Double(index)
            let distance = abs(position - phase)
            let wrappedDistance = min(distance, Double(dotCount) - distance)
            let intensity = max(0.0, 1.0 - wrappedDistance)
            return 0.2 + (0.8 * intensity)
        }
    }
    
    // 🧬 혈통 구성원 블록
    @ViewBuilder
    private func FamilyMemberBlock(title: String, titleColor: Color, geckoName: String, geckoId: String, imageData: Data?, placeholderEmoji: String) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(titleColor))
            
            ZStack {
                Circle().stroke(Color.white, lineWidth: 2).frame(width: 100, height: 100)
                
                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                        // 🌟 [핵심 추가] 손가락으로 꾹~ 누를 때 확대 사진 데이터 세팅하기!
                        .onLongPressGesture(minimumDuration: 0.1, perform: {
                            // 누르기 완료 (비워둠)
                        }, onPressingChanged: { isPressing in
                            // 손을 대고 있으면(true) 사진 띄우기, 손을 떼면(false) 사진 없애기
                            zoomedImageData = isPressing ? data : nil
                        })
                } else {
                    Circle().fill(Color.secondary.opacity(0.1)).frame(width: 96, height: 96)
                    Text(placeholderEmoji).font(.system(size: 48))
                }
            }
            
            VStack(spacing: 3) {
                Text(geckoName).font(.system(size: 15, weight: .bold)).foregroundColor(.black)
                Text(geckoId).font(.system(size: 12)).foregroundColor(.secondary)
            }
        }
        .frame(width: 120)
    }
}
