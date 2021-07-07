function [ Ratio, BootRatio, MeanRatios, CIRatios, Polarisation, MeanPolarisation] = polarRatios2( Profiles, CellWidths, CellLengths, k, BootN )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    fields=fieldnames(Profiles);
    mins=zeros(1,numel(fieldnames(Profiles)));

    vals=zeros(length(mins), 1);

    for i=1:length(mins)
        Ratio.(char(fields(i))) = vals;
    end

    MeanRatios=zeros(numel(fieldnames(Profiles)),1);
    MeanPolarisation=zeros(numel(fieldnames(Profiles)),1);
    CIRatios=zeros(numel(fieldnames(Profiles)),2);
    NbCells=zeros(numel(fieldnames(Profiles)),1);
    NbCellsDiffused=zeros(numel(fieldnames(Profiles)),1);

    for biorep=1:length(mins)
    %     figure();
        n=0;
        NbCells(biorep)=size(Profiles.(char(fields(biorep))),1);
        dim=floor(sqrt(NbCells(biorep)))+1;
    %     disp(strcat('n cells :',NbCells(biorep)));
    %     disp(strcat('dimension :',dim));
        PolarRatio=zeros(1,NbCells(biorep));
        Polarism=zeros(1,NbCells(biorep));
        for cell=1:NbCells(biorep)
            RangePoles=(CellWidths.(char(fields(biorep)))(cell))/(CellLengths.(char(fields(biorep)))(cell))*0.5;
            %disp(strcat('Pole range :', num2str(RangePoles*100), '%'));
            StartRange=min(find(k>=(RangePoles)));
            EndRange=max(find(k<=(1-RangePoles)));
            %disp(strcat('Start :', num2str(StartRange), ', End :', num2str(EndRange)));
            profile=Profiles.(char(fields(biorep)))(cell,:);
            MiddleFluorescence=mean(profile(StartRange:EndRange));
            SDMiddleFluorescence=std(profile(StartRange:EndRange));
            %disp(strcat('Middle fluorescence :', num2str(2*MiddleFluorescence)));
            Midline=ones(1,length(k))*MiddleFluorescence;
            AreaDiffusedStart=trapz(Midline(1,StartRange));
            AreaDiffusedEnd=trapz(Midline(EndRange:end));
%             AreaDiffused=AreaDiffusedStart+AreaDiffusedEnd;
            AreaStart=trapz(profile(1:StartRange));
            AreaEnd=trapz(profile(EndRange:end));
            MaxStart=maxN(profile(1:StartRange),1);
            MaxEnd=maxN(profile(EndRange:end),1);
            %AreaMiddle=trapz(profile(StartRange:EndRange));
            if (((AreaStart-AreaDiffusedStart)>0) && (MaxStart>(MiddleFluorescence+2*SDMiddleFluorescence)))
                I1=(AreaStart-AreaDiffusedStart);
            else
                I1=0;
            end
            if (((AreaEnd-AreaDiffusedEnd)>0) && (MaxEnd>(MiddleFluorescence+2*SDMiddleFluorescence)))
                I2=(AreaEnd-AreaDiffusedEnd);
            else
                I2=0;
            end
            PolarRatio(cell) = ((I1+I2)/(AreaStart+AreaEnd));
    %         PolarRatio(cell) = ((AreaStart+AreaEnd-AreaDiffused)/(AreaStart+AreaEnd));
            I1=(AreaStart);
            I2=(AreaEnd);
    %         I1=(AreaStart-AreaDiffusedStart);
    %         I2=(AreaEnd-AreaDiffusedEnd);
            if(I1>=I2)
                Imax=I1;
            else
                Imax=I2;
            end
            if((I1+I2)>0)
                Polarism(cell) = Imax/(I1+I2);
            else
                Polarism(cell) = 0.5;
                n=n+1;
            end
            if (I2<0)
                disp(strcat('I1 :', num2str(I1), ', I2 :', num2str(I2), ', I1+I2 :', num2str(I1+I2)));
                disp(strcat('PolarRatio :', num2str(PolarRatio(cell))));
                disp(strcat('MaxStart :', num2str(MaxStart), ' MaxEnd :', num2str(MaxEnd), ' Middle fluorescence :', num2str(MiddleFluorescence), ' Middle fluorescence SD:', num2str(SDMiddleFluorescence)));
            end
            %PolarRatio(cell)=(AreaStart+AreaEnd)/trapz(profile);
            %PolarRatio(cell)=(abs(trapz(profile)-2*AreaDiffused-AreaDiffused)/trapz(profile));
    %         subplot(dim,dim,cell);
    %         plot(k,profile);
    %         
    %         hold on;
    %         plot(k, Midline);
        end
        NbCellsDiffused(biorep)=n;
        disp(strcat('Diffused cells :', num2str(NbCellsDiffused(biorep)),' over tot cells :', num2str(NbCells(biorep))));
        Ratio.(char(fields(biorep))) = PolarRatio;
        Polarisation.(char(fields(biorep))) = Polarism(~isnan(Polarism));
        BootRatio.(char(fields(biorep))) =  bootstrp(BootN, @(x) median(x), PolarRatio);
        MeanRatios(biorep)=median(Ratio.(char(fields(biorep))));
        MeanPolarisation(biorep)=median(Polarisation.(char(fields(biorep))));
        CIRatios(biorep,:)=ci_percentile(Ratio.(char(fields(biorep))));
    end
end

