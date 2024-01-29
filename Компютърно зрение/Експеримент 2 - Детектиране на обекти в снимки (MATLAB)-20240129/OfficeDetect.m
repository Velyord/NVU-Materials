%Стъпка 1: Прочитане на изображение
%Прочита се референтното изображение, съдържащо обекта на интерес.
clear
clc
boxImage = imread('box.jpg'); % Изображението се прочита
boxImage = rgb2gray(boxImage);% Пробразуване на цветно изображение 
% в черно-бяло с вградена функция
figure; % Извежда се на дисплея прозорец за фигура
imshow(boxImage); % изобразява се прочетенеото изображение във фигурата
title('Image of a box'); % Присвоява се име на получената фигура
% На следващ етап се прочита целевото изображение в разхвърлена сцена.
toolsImage = imread('tools.jpg');
toolsImage = rgb2gray(toolsImage);
figure;
imshow(toolsImage); % Изобразяване на изображението 
title('Image of a tools');% назначаване на заглавие на фигурата

%Стъпка 2: Откриване на точкови характеристики
%Откриване на точкови характеристики в двете изображения.
boxPoints = detectSURFFeatures(boxImage); % Създава се променлива с резултата 
% от ретекцията на характеристични точки на кутията
toolsPoints = detectSURFFeatures(toolsImage); % Създава се променлива с резултата от 
% ретекцията на характеристични точки на цялоото изображение
%Визуализиране на най-силните черти на референтното изображение.
figure;
imshow(boxImage);
title('100 Strongest Point Features from box Image');
hold on;
plot(selectStrongest(boxPoints, 100)); % Изчертаване на най-контрастните 100 точки
%Визуализиране на най-силните характеристики на целевото изображение.
figure;
imshow(toolsImage);
title('300 Strongest Point Features from tools Image');
hold on; % оставя се като изходно изображение за лседващата стъпка
plot(selectStrongest(toolsPoints, 300)); % Изчертаване на най-контрастните 300 точки върху изходното изображение

%Стъпка 3: Извличане на характеристики
%Можете да извлечете характеристиките на интересните точки и в двете изображения.
[boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints); %
[toolsFeatures, toolsPoints] = extractFeatures(toolsImage, toolsPoints);

%Стъпка 4: Намиране на предполагаемо съвпадащи характеристики
boxPairs = matchFeatures(boxFeatures, toolsFeatures); % създаване на променлива със стойности на съвпадащи по стойност точки
%Изобразяване на съвпадащи характеристики
matchedboxPoints = boxPoints(boxPairs(:, 1), :);
matchedtoolsPoints = toolsPoints(boxPairs(:, 2), :);
figure;
showMatchedFeatures(boxImage, toolsImage, matchedboxPoints, ...
matchedtoolsPoints, 'montage');
title('Putatively Matched Points (Including Outliers)');

%Стъпка  5: Локализиране на обекта в сцената с помощта на предполагаеми съвпадения
% Функцията evaluationGeometricTransform изчислява трансформацията, свързваща съвпадащите точки,
% като същевременно елиминира извънредните стойности. 
% Тази трансформация ви позволява да локализирате обекта в сцената.

[tform, inlierboxPoints, inliertoolsPoints] = ...
estimateGeometricTransform(matchedboxPoints, matchedtoolsPoints,...
'affine');
%След това можете да покажете съвпадащите двойки точки 
% с премахнати извънредни стойности
figure;
showMatchedFeatures(boxImage, toolsImage, inlierboxPoints, ...
inliertoolsPoints, 'montage');
title('Matched Points (Inliers Only)');
%След това може да се образува ограничаващия многоъгълник 
% на референтното изображение
boxPolygon = [1, 1;...  % горе вляво
size(boxImage, 2), 1;...  % горе вдясно
size(boxImage, 2), size(boxImage, 1);...  % долу вдясно
1, size(boxImage, 1);...  % долу вляво
1, 1];  % отново горе вляво за затваряне на полигона
%За да се посочи местоположението на обекта в сцената, може да се трансформира
% многоъгълника в координатна система на целевото изображение.
newboxPolygon = transformPointsForward(tform, boxPolygon);
% След това може да се изобрази детектирания обект:
figure;
imshow(toolsImage);
hold on;
line(newboxPolygon(:, 1), newboxPolygon(:, 2), 'Color', 'y');
title('Detected box');
% Локализиране на обекта в сцената 
% с помощта на предполагаеми съвпадения


% Стъпка 6: Откриване на друг обект
% Можете да откриете втори обект,
% като използвате същите стъпки като преди. 
% Започнете, като прочетете изображение, съдържащо
% втори обект на интерес - rubber.jpg
rubberImage = imread('rubber.jpg');
rubberImage = rgb2gray(rubberImage);% Пробразуване на цветно изображение 
% в черно-бяло с вградена функция
figure;
imshow(rubberImage);
title('Image of an rubber');
% След това открийте и визуализирайте характерни точки.
rubberPoints = detectSURFFeatures(rubberImage);
figure;
imshow(rubberImage);
hold on;
plot(selectStrongest(rubberPoints, 100));
title('100 Strongest Feature Points from rubber Image');
% Извличане на характеристики
[rubberFeatures, rubberPoints] = extractFeatures(rubberImage, ...
rubberPoints);
% Намиране на предполагаемо съвпадащи характеристики
rubberPairs = matchFeatures(rubberFeatures, toolsFeatures, ...
'MaxRatio', 0.9);
% Изобразяване на предполагаемо съвпадащи характеристики
matchedrubberPoints = rubberPoints(rubberPairs(:, 1), :);
matchedtoolsPoints = toolsPoints(rubberPairs(:, 2), :);
figure;
showMatchedFeatures(rubberImage, toolsImage, matchedrubberPoints, ...
matchedtoolsPoints, 'montage');
title('Putatively Matched Points (Including Outliers)');
%Локализиране на обекта в сцената с помощта 
% на предполагаеми съвпадения, 
% като същевременно се елиминират извънредните стойности
% Локализиране на обекта в сцената.
[tform, inlierrubberPoints, inliertoolsPoints] = ...
estimateGeometricTransform(matchedrubberPoints, ...
matchedtoolsPoints, 'affine');
figure;
showMatchedFeatures(rubberImage, toolsImage, inlierrubberPoints, ...
inliertoolsPoints, 'montage');
title('Matched Points (Inliers Only)');
 
%изобразяване на двата обекта:
rubberPolygon = [1, 1;...  % top-left
size(rubberImage, 2), 1;...  % top-right
size(rubberImage, 2), size(rubberImage, 1);... % bottom-right
1, size(rubberImage, 1);...  % bottom-left
1,1];  % top-left again to close the polygon
newrubberPolygon = transformPointsForward(tform, rubberPolygon);
figure;
imshow(toolsImage);
hold on;
line(newboxPolygon(:, 1), newboxPolygon(:, 2), 'Color', 'y');
line(newrubberPolygon(:, 1), newrubberPolygon(:, 2), 'Color', 'g');
title('Detected rubber and box');

