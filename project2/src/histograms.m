function histograms(T)
    figure(1)
    for i=1:27
        subplot(3,9,i)
        idx=[T(:,end)==1];
        hold on
        hist(T(idx,i))
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','EdgeColor','w','facealpha',0.75)
        hist(T(~idx,i))
        h2 = findobj(gca,'Type','patch');
        set(h2,'facealpha',0.75);
        hold off
    end
end