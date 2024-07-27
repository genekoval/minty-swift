import Foundation

extension UUID {
    init(staticString string: StaticString) {
        guard let uuid = UUID(uuidString: "\(string)") else {
            preconditionFailure("Invalid static UUID string: \(string)")
        }

        self = uuid
    }
}

struct Comments {
    static let world =
        UUID(staticString: "483A1E30-9946-4721-B2B0-91DC726526EE")
}

struct Objects {
    static let bunny =
        UUID(staticString: "21B700D0-724F-4642-8F50-C5B8FBFFE6C9")
    static let sand = UUID(staticString: "49B870E4-1B21-4FEB-9A3F-4A3FFD101204")
}

struct Posts {
    // Programming Languages
    static let c = UUID(staticString: "9BB115BC-9A32-4D13-9F0B-F38CE3A18BC0")
    static let cpp = UUID(staticString: "E0FAC289-D8B9-4435-B73E-D11007D879DA")
    static let java = UUID(staticString: "21CFD03E-BE9C-4549-9758-C0696088122B")
    static let js = UUID(staticString: "4A2C7232-8A70-46BA-957B-50293B08BB73")
    static let rust = UUID(staticString: "06B8413B-5DD7-4B87-A183-34552608DDEB")

    // Media
    static let bunny =
        UUID(staticString: "5CF6BC10-DB1F-4159-BA96-5C075CE3A072")
    static let comments =
        UUID(staticString: "F4D63CB8-46BC-455F-94A0-86476940327A")
    static let sand = UUID(staticString: "80E0C042-BEEF-4A30-99AC-07063327D01A")
}

struct Tags {
    static let languages =
        UUID(staticString: "7D0F4F2C-A08E-4A70-B71A-AE9EA54FFC6E")
    static let videos =
        UUID(staticString: "04A7B298-3D23-4916-A2C7-62FB201FC40D")
}

struct Users {
    static let minty =
        UUID(staticString: "99786976-95bd-49ff-892e-cd76580aec5a")
}
