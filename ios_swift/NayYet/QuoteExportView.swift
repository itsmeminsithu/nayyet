import SwiftUI
import Photos

struct QuoteExportView: View {
    let monthlyAsset: String
    let text: String
    let date: String
    let mm: Bool
    @State private var skyline = false
    @State private var monthly = true
    @State private var exportURL: URL?
    @State private var status = ""
    @State private var busy = false
    private func t(_ my:String,_ en:String)->String { mm ? my : en }
    private var artwork: some View {
        ZStack {
            LinearGradient(colors: skyline ? [Color(red:0.14,green:0.15,blue:0.27),Color(red:0.72,green:0.40,blue:0.51),Color(red:0.95,green:0.73,blue:0.58)] : [Color(red:0.03,green:0.05,blue:0.18),Color(red:0.22,green:0.15,blue:0.39),Color(red:0.58,green:0.39,blue:0.51)],startPoint:.top,endPoint:.bottom)
            Canvas { context,size in
                for i in 0..<95 {
                    let x=Double((i*173+41)%1080)/3, y=Double((i*277+29)%1100)/3
                    context.fill(Path(ellipseIn:CGRect(x:x,y:y,width:Double(2+i%3),height:Double(2+i%3))),with:.color(.white.opacity(0.5)))
                }
                context.fill(Path(ellipseIn:CGRect(x:252,y:55,width:50,height:50)),with:.color(Color(red:0.97,green:0.87,blue:0.74)))
                if skyline {
                    for i in 0..<16 {
                        let h=Double(100+(i*79)%230)/3
                        context.fill(Path(CGRect(x:Double(i)*24,y:450-h,width:22,height:h)),with:.color(Color(red:0.07,green:0.10,blue:0.20)))
                    }
                } else {
                    context.stroke(Path(ellipseIn:CGRect(x:227,y:67,width:100,height:27)),with:.color(.white.opacity(0.3)),lineWidth:0.6)
                }
            }
            if monthly { Image(monthlyAsset).resizable().scaledToFill().frame(width:360,height:450).clipped().overlay(.black.opacity(0.36)) }
            VStack(alignment:.leading,spacing:16) {
                Text("NAYYET / A MOMENT FOR YOU").font(.custom("Outfit-Thin",size:10))
                Spacer()
                Text(text).font(.custom(mm ? "Pyidaungsu" : "Outfit-Thin",size:20)).lineSpacing(9).fixedSize(horizontal:false,vertical:true)
                Spacer()
                Text(date).font(.custom(mm ? "Pyidaungsu" : "Outfit-Thin",size:10))
                Text("နေ့ရက် — NayYet · minsithu.org").font(.custom("Pyidaungsu",size:10))
            }.foregroundStyle(.white).padding(30).padding(.bottom,25).frame(maxWidth:.infinity,alignment:.leading)
        }.frame(width:360,height:450)
    }
    var body: some View {
        ScrollView {
            VStack(spacing:18) {
                Toggle(t("လအလိုက် နောက်ခံ","Monthly theme"),isOn:$monthly).onChange(of:monthly){_,_ in exportURL=nil}
                if !monthly { Toggle(skyline ? "Skyline" : "Universe",isOn:$skyline).onChange(of:skyline){_,_ in exportURL=nil} }
                ViewThatFits { artwork; artwork.scaleEffect(0.8).frame(width:288,height:360) }
                Button(t("PNG ပြင်ဆင်ရန်","Prepare PNG")){prepare()}.disabled(busy)
                if let exportURL {
                    ShareLink(item:exportURL){Label(t("မျှဝေရန် / Files တွင်သိမ်းရန်","Share / Save to Files"),systemImage:"square.and.arrow.up")}
                    Button(t("Photos တွင်သိမ်းရန်","Save to Photos")){savePhoto(exportURL)}.disabled(busy)
                }
                Text(status).font(.caption)
            }.padding(20)
        }
    }
    @MainActor private func prepare() {
        do {
            let renderer=ImageRenderer(content:artwork);renderer.scale=3
            guard let data=renderer.uiImage?.pngData() else { throw CocoaError(.fileWriteUnknown) }
            let url=FileManager.default.temporaryDirectory.appendingPathComponent("nayyet-quote-\(UUID().uuidString).png")
            try data.write(to:url,options:.atomic);exportURL=url
            status=t("၁၀၈၀ × ၁၃၅၀ PNG အသင့်ဖြစ်ပါပြီ။","1080 × 1350 PNG ready.")
        } catch { status=t("ပုံထုတ်မရပါ။ ပြန်စမ်းပါ။","Could not create the image.") }
    }
    private func savePhoto(_ url:URL) {
        busy=true
        PHPhotoLibrary.requestAuthorization(for:.addOnly){authorization in
            guard authorization == .authorized || authorization == .limited else {
                DispatchQueue.main.async{busy=false;status=t("Photos ခွင့်ပြုချက်လိုသည်။ Files တွင်လည်း သိမ်းနိုင်သည်။","Photos access was denied. You can still save to Files.")};return
            }
            PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL:url)}){saved,_ in
                DispatchQueue.main.async{busy=false;status=saved ? t("Photos တွင် သိမ်းပြီးပါပြီ။","Saved to Photos.") : t("သိမ်းမရပါ။","Could not save.")}
            }
        }
    }
}
