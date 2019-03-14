package edu.gmu.css.entities;

import edu.gmu.css.relations.BorderAgreement;
import edu.gmu.css.relations.BorderRelation;
import org.neo4j.ogm.annotation.*;

import java.util.Set;

@NodeEntity
public class Border extends Institution {
    /**
     *
     */
    @Id @GeneratedValue
    private Long id;
    @Property
    private Long from;
    @Property
    private Long until;
    @Property
    private int year;
    @Relationship (type = "BORDERS", direction=Relationship.INCOMING)
    private Set<BorderRelation> borderRelationSet;
    @Relationship (type="SHARES_BORDER", direction = Relationship.INCOMING)
    private Set<BorderAgreement> borderPartners;

    // only for the OGM, don't use this otherwise
    public Border() {
    }

    public Territory getNeighborTerritory(BorderRelation a) {
        for (BorderRelation borderRelation : borderRelationSet) {
            if (!borderRelation.equals(a)) {
                return borderRelation.getSelf();
            }
        }
        return null;
    }

    public Polity findBorderPartner(BorderAgreement agreement) {
        for (BorderAgreement partner : borderPartners) {
            if (!partner.equals(agreement)) {
                return partner.getParticipant();
            }
        }
        return null;
    }


    public static class BorderBuilder {
        private Set<BorderAgreement> borderPartners;
        private Set<BorderRelation> borderRelations;
        private Long from;
        private Long until;
        private int year;
        private Resources maintenance;

        public BorderBuilder() {        }


        public BorderBuilder borderRelations (Set<BorderRelation> neighbors) {
            this.borderRelations = neighbors;
            return this;
        }

        public BorderBuilder borderPartners (Set<BorderAgreement> partners) {
            this.borderPartners = partners;
            return this;
        }

        public BorderBuilder from (Long from) {
            this.from = from;
            return this;
        }

        public BorderBuilder until (Long until) {
            this.until = until;
            return this;
        }

        public BorderBuilder year (int year) {
            this.year = year;
            return this;
        }

        public BorderBuilder maintenance (Resources cost) {
            this.maintenance = cost;
            return this;
        }

        public Border build() {
            Border border = new Border();
            return border;
        }

    }

    private Border(BorderBuilder builder) {
        this.borderRelationSet = builder.borderRelations;
        this.borderPartners = builder.borderPartners;
        this.from = builder.from;
        this.until = builder.until;
        this.maintenance = builder.maintenance;
        this.year = builder.year;
    }

    public Long getId() {
        return id;
    }

    public Resources getCommitment() {
        return maintenance;
    }

    public void setCommitment(Resources commitment) {
        this.maintenance = commitment;
    }

    public Long getFrom() {
        return from;
    }

    public void setFrom(Long from) {
        this.from = from;
    }

    public Long getUntil() {
        return until;
    }

    public void setUntil(Long until) {
        this.until = until;
    }

    @Override
    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public Set<BorderRelation> getBorderRelationSet() {
        return borderRelationSet;
    }

    public void setBorderRelationSet(Set<BorderRelation> borderRelationSet) {
        this.borderRelationSet = borderRelationSet;
    }

    public Set<BorderAgreement> getBorderPartners() {
        return borderPartners;
    }

    public void setBorderPartners(Set<BorderAgreement> borderPartners) {
        this.borderPartners = borderPartners;
    }
}
