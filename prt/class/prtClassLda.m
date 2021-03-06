classdef prtClassLda < prtClass
 %prtClassLda Linear Discriminant Analsysis
 % 
 %    classifier = prtClassLda returns a linear discriminant classifier.
 %
 %      See: http://en.wikipedia.org/wiki/Linear_discriminant_analysis#LDA_for_two_classes
 %
 % Example
 %    ds1 = prtDataGenUnimodal;       % Create some test and
 %    ds2 = prtDataGenUnimodal;   % training data
 %    classifier = prtClassLda;           % Create a classifier
 %    classifier = classifier.train(ds1);    % Train
 %    classified = run(classifier, ds2);         % Test
 %    subplot(2,1,1);
 %    classifier.plot;
 %    subplot(2,1,2);
 %    [pf,pd] = prtScoreRoc(classified);
 %    h = plot(pf,pd,'linewidth',3);
 %    title('ROC'); xlabel('Pf'); ylabel('Pd');
 
% Copyright (c) 2013 New Folder Consulting 
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


 

    properties (SetAccess=private)
        
        name = 'LDA'  
        nameAbbreviation = 'LDA'         
        isNativeMary = false; 
    end
    
    properties (SetAccess = protected)
        % w is a dataSet.nDimensions x 1 vector of projection weights
        % learned during Fld.train(dataSet)
        
        w = []; % The vector of weights, learned during training
        
    end
    
    methods
     
               % Allow for string, value pairs
        function self = prtClassLda(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            
            n = dataSet.nObservations;
            p = dataSet.nFeatures;
            
            if p > n
                warning('prt:prtClassFld:train:illconditioned','dataSet has n (%d) < p (%d); prtClassFld may not be stable',n,p);
            end
            if ~dataSet.isBinary
                error('prtClassFld:nonBinaryTraining','Input dataSet for prtClassFld.train must be binary');
            end
            
            
            dataH0 = dataSet.getObservationsByClassInd(1);
            dataH1 = dataSet.getObservationsByClassInd(2);
            
            mean0 = mean(dataH0,1);
            mean1 = mean(dataH1,1);
            
            % LDA
            covW = cov(cat(1,bsxfun(@minus,dataH0,mean0),bsxfun(@minus,dataH1,mean1)));
            self.w = covW\(mean1-mean0)'; %w = covW^-1 * (mean1-mean0)'; % But better
            self.w = self.w./norm(self.w);
            
        end
        
        function dataSet = runAction(self,dataSet)
            dataSet = prtDataSetClass((self.w'*dataSet.getObservations()')');
        end
        
    end
    
end
