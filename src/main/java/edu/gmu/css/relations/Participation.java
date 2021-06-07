package edu.gmu.css.relations;


import edu.gmu.css.data.Resources;
import edu.gmu.css.entities.Institution;
import edu.gmu.css.entities.Polity;
import edu.gmu.css.entities.War;
import org.neo4j.ogm.annotation.*;

import java.io.Serializable;


@RelationshipEntity(type="PARTICIPATION")
public class Participation extends InstitutionParticipation implements Serializable {

    @Id @GeneratedValue
    private Long id;
    @StartNode
    Polity owner;
    @EndNode
    War institution;
    @Property
    private Double magnitude;          // losses, not participation
    @Property
    private int side;
    @Transient
    private Resources commitment;


    public Participation() {
    }

    public Participation(ProcessDisposition disposition, Institution institution, Long step) {
        this.institution = (War) institution;
        this.owner = disposition.getOwner();
        this.commitment = disposition.getCommitment();
        this.from = step;
        this.magnitude = 0.0;
    }

    public Participation(Polity p, Resources c, Long s) {
        this.owner = p;
        this.commitment = c;
        this.from = s;
        this.magnitude = 0.0;
    }

    public Participation(ProcessDisposition disposition, Institution institution) {
        ProcessDisposition pd = disposition;
        this.institution = (War) institution;
        this.owner = pd.getOwner();
        this.commitment = pd.getCommitment();
        this.from = pd.getFrom();
        this.magnitude = 0.0;
    }


    @Override
    public Long getId() {
        return id;
    }

    @Override
    public Resources getCommitment() {
        return commitment;
    }

    @Override
    public void setCommitment(Resources commitment) {
        this.commitment = commitment;
    }

    @Override
    public void commitMore(Resources additional) {
        commitment.increaseBy(additional);
    }

//    @Override
//    public void tallyLosses(double rate, WorldOrder wo) {
//        WorldOrder worldOrder = wo;
//        int pLoss = (int) Math.round(rate * commitment.getPax());
//        double tLoss = rate * commitment.getTreasury();
//        Resources loss = new Resources.ResourceBuilder().pax(pLoss).treasury(tLoss).build();
//        commitment.reduceBy(loss);
//        cost.increaseBy(loss);
//        owner.getSecurityStrategy().addSupplemental(this, loss);
//        magnitude += pLoss;
////        if (commitment.getPax() < 0) {
////            // TODO: implement consequences for losing the war; for now, just end it.
////            institution.conclude(worldOrder);
////            owner.surrender(this, worldOrder);
////        }
//
//        ProcessDisposition pd = owner.getProcessList().stream()
//                .filter(d -> institution.equals(d.getSubject()))
//                .findAny().orElse(null);
//        if (pLoss * 2 > commitment.getPax()) {
//            if (pd == null) {
//                owner.evaluateNeedForPeace(worldOrder, )
//                owner.considerPeace(institution, worldOrder);
//            } else {
//                pd.setN(true);
//            }
//        }
//    }



}
