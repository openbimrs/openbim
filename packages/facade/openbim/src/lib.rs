//! `openbim` — a facade over the openBIM standards.
//!
//! Enable only what you need:
//!
//! ```toml
//! openbim = { version = "0.1", features = ["ids"] }
//! ```
//!
//! # Why the standards are separate crates
//!
//! Cargo features are **additive across the whole dependency graph**. If every
//! standard were a feature of one crate, then any dependency anywhere enabling
//! `icdd` would make *everyone* compile an RDF stack — including a consumer
//! that only wanted to read a `.ids` file.
//!
//! Separate packages make that structurally impossible: a crate not named in
//! your feature set is never built. This facade exists so the convenience of
//! one dependency line is still available, and it re-exports only. See
//! `docs/adr/0015`.
//!
//! # Available features
//!
//! | Feature | Crate | Standard |
//! | --- | --- | --- |
//! | `dt` | `openbim-dt` | ISO 23387 data templates |
//! | `ids` | `openbim-ids` | buildingSMART IDS |
//! | `gaeb` | `openbim-gaeb` | GAEB DA XML |
//! | `citygml` | `openbim-citygml` | OGC CityGML (reserved scaffold) |
//! | `openbimrl` | `openbim-openbimrl` | OpenBIM.rs namespace (reserved scaffold) |
//! | `bsdd` | `openbim-bsdd` | buildingSMART Data Dictionary (reserved scaffold) |
//! | `epd` | `openbim-epd` | ISO 22057 EPD data templates |
//! | `bcf` | `openbim-bcf` | BCF (BIM Collaboration Format) |
//! | `icdd` | `openbim-icdd` | ISO 21597 ICDD |
//! | `idm` | `openbim-idm` | ISO 29481-3 idmXML |
//! | `loin` | `openbim-loin` | ISO 7817-3 / EN 17412-3 LOIN |
//! | `mvd` | `openbim-mvd` | buildingSMART mvdXML 1.1 |
//! | `full` | all of the above | |
//!
//! `loin` implies `dt`, because the LOIN schema imports ISO 23387.
//!
//! No feature is on by default: depending on `openbim` must never cost more
//! than the shared vocabulary in [`core`].
//!
//! # Status
//!
//! **Mixed maturity.** [`core`] carries shared vocabulary and the `gaeb`
//! feature exposes a working lossless reader/editor. Other standard families
//! publish their own capability boundaries; enabling a feature does not imply
//! full schema validation.

#![forbid(unsafe_code)]

/// Vocabulary shared by every standard: outcomes, element references,
/// version detection. Always available.
pub use openbim_core as core;

#[cfg(feature = "dt")]
pub use openbim_dt as dt;

#[cfg(feature = "ids")]
pub use openbim_ids as ids;

#[cfg(feature = "gaeb")]
pub use openbim_gaeb as gaeb;

#[cfg(feature = "citygml")]
pub use openbim_citygml as citygml;

#[cfg(feature = "mvd")]
pub use openbim_mvd as mvd;

#[cfg(feature = "openbimrl")]
pub use openbim_openbimrl as openbimrl;

#[cfg(feature = "bsdd")]
pub use openbim_bsdd as bsdd;

#[cfg(feature = "epd")]
pub use openbim_epd as epd;

#[cfg(feature = "bcf")]
pub use openbim_bcf as bcf;

#[cfg(feature = "icdd")]
pub use openbim_icdd as icdd;

#[cfg(feature = "idm")]
pub use openbim_idm as idm;

#[cfg(feature = "loin")]
pub use openbim_loin as loin;

#[cfg(test)]
mod tests {
    /// The shared vocabulary is reachable with no features enabled.
    #[test]
    fn core_is_always_available() {
        assert!(crate::core::Outcome::Failed.is_applicable());
        assert!(!crate::core::Outcome::NotApplicable.is_applicable());
    }

    /// The GAEB feature re-exports the standalone lossless DA XML crate.
    #[test]
    #[cfg(feature = "gaeb")]
    fn gaeb_feature_reexports_document_contract() {
        let document = crate::gaeb::Document::parse(
            br#"<GAEB xmlns="http://www.gaeb.de/GAEB_DA_XML/DA83/3.3"><GAEBInfo><Version>3.3</Version></GAEBInfo><Award><DP>83</DP></Award></GAEB>"#,
        )
        .unwrap();
        assert_eq!(
            document.metadata().phase,
            Some(crate::gaeb::ExchangePhase::X83)
        );
    }

    /// The EPD feature re-exports the standalone ISO 22057 crate.
    #[test]
    #[cfg(feature = "epd")]
    fn epd_feature_reexports_iso_22057_contracts() {
        assert_eq!(
            crate::epd::StandardEdition::CURRENT.designation(),
            "ISO 22057:2022"
        );
        assert_eq!(crate::epd::InformationModule::ALL.len(), 18);
    }

    /// The MVD feature re-exports the standalone mvdXML 1.1 toolkit.
    #[test]
    #[cfg(feature = "mvd")]
    fn mvd_feature_reexports_document_contract() {
        let document = crate::mvd::MvdXml::from_xml(
            r#"<mvdXML xmlns="http://buildingsmart-tech.org/mvd/XML/1.1" uuid="00000000-0000-4000-8000-000000000001" name="facade"/>"#,
        )
        .unwrap();
        assert!(document.is_valid());
    }

    /// `loin` must imply `dt` — the LOIN schema imports ISO 23387, so a build
    /// with LOIN but no data templates would be incoherent.
    #[test]
    #[cfg(feature = "loin")]
    fn loin_implies_dt() {
        assert!(crate::loin::is_known_namespace(crate::loin::NAMESPACE_2024));
        assert!(!crate::dt::NAMESPACE.is_empty());
    }
}
